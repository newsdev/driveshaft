require 'jwt'
require 'typhoeus'
module Auth
  class IAPVerifier

    ##
    # Example usage:
    # (in config.ru)
    #
    # ```
    # require 'badcom/IAPVerifier'
    # use Badcom::IAPVerifier, skip_paths: ["/skip"]
    # ```
    #
    # OPTIONS:
    # skip_paths: an array of paths to skip. Publically accessable paths should be listed here.
    # 
    # ENVARS
    # ENV['IAP_SKIP_AUTH']: disables iap verification for all incoming requests.
    # ENV['IAP_EMAIL_WHITELIST']: comma seperated list of emails and domains to whitelist. defaults to @nytimes.com
    #
    def initialize(app, options={})
      @app, @options, @key_cache = app, options, {}

      @skip_hoist = !ENV['IAP_SKIP_HOIST'].nil?
      @skip_auth = !ENV['IAP_SKIP_AUTH'].nil?
      @rackenv = ENV['RACK_ENV']
      envar_whitelist = (ENV['IAP_EMAIL_WHITELIST'] || '@nytimes.com').split(',').map(&:strip)

      @domain_whitelist = envar_whitelist.select{ |itm| itm[0] == '@' }
      @email_whitelist = envar_whitelist.select{ |itm| itm[0] != '@' }

      @logger = Logger.new(STDOUT)
    end

    def return_forbidden(logger_message, request, override_response=false)
      @logger.info  "REQUEST FORBIDDEN: BASEURL [#{request.base_url}], EMAIL [#{request.env['auth.verified_email']}], IP [#{request.ip}], XFORWARDEDFOR [#{request.env['HTTP_X_FORWARDED_FOR']}], PATH [#{request.path_info}], REASON [#{logger_message}]"
      [403, {"Content-Type" => "text/plain"}, [ override_response ? logger_message : 'FORBIDDEN (BADCOM). SEE APPLICATION LOGS FOR DETAILS']]
    end

    def continue_request(env, request, message)
      @logger.info "REQUEST PERMITTED: BASEURL [#{request.base_url}], EMAIL [#{request.env['auth.verified_email']}], IP [#{request.ip}], XFORWARDEDFOR [#{request.env['HTTP_X_FORWARDED_FOR']}], PATH [#{request.path_info}], REASON [#{message}]"
      iaap_auth_cookie = request.params['cookie'] #request.cookies['GCP_IAAP_AUTH_TOKEN']

      return @app.call(env) if (iaap_auth_cookie.nil? || @skip_hoist)
      
      begin
        #unverified = JWT.decode(iaap_auth_cookie, nil, false)
        #@logger.info "UNVERIFIED TOKEN #{'.'+request.host.split('.')[1..-1].join('.')}"
        #exp = unverified[0]['exp']
        status, headers, body = @app.call(env)
        response = Rack::Response.new body, status, headers
        response.set_cookie("GCP_IAAP_AUTH_TOKEN", {value: iaap_auth_cookie, domain: '.'+request.host.split('.')[1..-1].join('.'), path: "/", expires: Time.now+24*60*60})
        response.set_cookie("GCP_IAAP_AUTH_TOKEN2", {value: iaap_auth_cookie, domain: '.'+request.host.split('.')[1..-1].join('.'), path: "/", expires: Time.now+24*60*60})
        return response.finish
      rescue
        @logger.info "RESCUE COOKIE SETTING #{errors}"
        return @app.call(env)
      end

    end

    def decode(token, api_key)
      pub = OpenSSL::PKey::EC.new  api_key
      JWT.decode token, pub, true, { :algorithm => 'ES256' }
    end

    def allow_email?(verified_email)
      domain = '@' + verified_email.split('@')[1]

      if @domain_whitelist.include? domain
        return true
      end
      
      if @email_whitelist.include? verified_email
        return true
      end
      return false
    end

    def call(env)
      request = Rack::Request.new(env)

      if @skip_auth
        env['auth.skipped'] = 'envar'
        return continue_request(env, request, "IAP_SKIP_AUTH ACTIVATED")
      end

      # Whitelist requests if in dev or test
      if @rackenv == 'development' || @rackenv == 'test'
        env['auth.skipped'] = "rackenv"
        env['auth.rackenv'] = @rackenv
        return continue_request(env, request, "RACK_ENV DEV/TEST")
      end

      # Check route whitelist
      if @options[:skip_paths] && @options[:skip_paths].any? { |skip| skip.match(request.path) }
        env['auth.skipped'] = 'route'
        return continue_request(env, request, "ROUTE WHITELIST")
      end

      # Whitelist cluster.local requests
      if request.ip.to_s.match /^10\./
        env['auth.skipped'] = 'ip'
        return continue_request(env, request, "IP WHITELIST")
      end

      # Whitelist localhost
      if request.ip == '127.0.0.1'
        env['auth.skipped'] = 'ip'
        return continue_request(env, request, "IP WHITELIST")
      end

      # Whitelist ssh tunnel
      if request.ip == '::1'
        env['auth.skipped'] = 'ip'
        return continue_request(env, request, "IP WHITELIST")
      end

      jwt_token = request.env['HTTP_X_GOOG_AUTHENTICATED_USER_JWT']
      header_email = request.env['HTTP_X_GOOG_AUTHENTICATED_USER_EMAIL']

      if ENV['IAP_VERBOSE']
        @logger.info "jwt_token: #{jwt_token}, header_email: #{header_email}"
      end

      if jwt_token.nil?
        return return_forbidden "REQUEST MISSING JWT TOKEN HEADER. IP: [#{request.ip}]", request
      end

      unverified = nil

      begin
        unverified = JWT.decode(jwt_token, nil, false)
        if ( unverified.nil? ||
          unverified[1].nil? ||
          unverified[1]['kid'].nil? ||
          unverified[0].nil? ||
          unverified[0]['sub'].nil? ||
          unverified[0]['email'].nil? )

          return return_forbidden "BAD JWT TOKEN, MISSING FIELDS. IP: [#{request.ip}]", request
        end
      rescue
        return return_forbidden "BAD JWT TOKEN, MALFORMED1. TOKEN [#{jwt_token}]", request
      end

      api_key = nil
      begin
        api_key = get_iap_key unverified[1]['kid']
      rescue
        @logger.info "500 ERROR: COULD NOT RETRIEVE PUBLIC KEY. IP [#{request.ip}], PATH [#{request.path_info}]"
        return [500, {"Content-Type" => "text/plain"}, ["COULD NOT RETRIEVE PUBLIC KEY"]]
      end

      begin
        decoded = decode(jwt_token, api_key)
        env['auth.verified_email'] = decoded[0]['email']
        env['auth.verified_sub'] = decoded[0]['sub']
        
        # Check that header email matches verified jwt email
        if header_email.gsub('accounts.google.com:', '') !=  decoded[0]['email']
          return return_forbidden "HEADER EMAIL DOES NOT MATCH JWT EMAIL. IP: [#{request.ip}]", request
        end
        
        # Check that email is in whitelist
        if !allow_email?( decoded[0]['email'])
          return return_forbidden "EMAIL NOT PERMITTED ACCESS. CONTACT APPLICATION OWNER. IP: [#{request.ip}]", request, true
        end
      
      rescue => e
        return return_forbidden "BAD JWT TOKEN. MALFORMED2. IP: [#{request.ip}], errors: #{errors}, e: #{e}", request
      end

      continue_request(env, request, 'NO SKIP')
    end

    # Returns key if key in @key_cache. 
    # Otherwise refresh cache from gstatic.com
    def get_iap_key(kid)

      return @key_cache[kid] if @key_cache.include? kid

      res = Typhoeus.get('https://www.gstatic.com/iap/verify/public_key')
      if res.code != 200
        raise 'Non 200 response from google key server'
      end
      @key_cache = JSON.parse(res.body)

      if @key_cache[kid].nil?
        raise 'key not found in response from google key server'
      end

      @key_cache[kid]
    end
  end
end