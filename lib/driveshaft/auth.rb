require 'google/api_client'
require './lib/driveshaft/version'

# Reopen the App class and enable sessions / google authentication
module Driveshaft
  class App

    if $settings[:auth][:required]
      before do
        if !web_client.authorization.access_token && !request.path_info.match(/^\/auth\//)
          redirect('/auth/authorize')
        end

      end
    end

    after do
      session[:access_token] = web_client.authorization.access_token
      session[:refresh_token] = web_client.authorization.refresh_token
      session[:expires_in] = web_client.authorization.expires_in
      session[:issued_at] = web_client.authorization.issued_at
    end

    def clients
      [(server_client if server_client.authorization.access_token),
       (web_client if web_client.authorization.access_token)
      ].compact
    end

    def server_client
      return @server_client if @server_client

      @server_client = Google::APIClient.new(
        application_name: 'Driveshaft',
        application_version: Driveshaft::VERSION
      )

      # First attempt to get a signing key from the environment
      if $google_service_account
        key = Google::APIClient::KeyUtils.load_from_pem($google_service_account['private_key'], 'notasecret')

        # If we found a signing key, then authenticate using it
        @server_client.authorization = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          audience: 'https://accounts.google.com/o/oauth2/token',
          scope: 'https://www.googleapis.com/auth/drive',
          issuer: $google_service_account['client_email'],
          signing_key: key
        )
        @server_client.authorization.fetch_access_token!

      # If not, then try to authenticate locally
      elsif $google_client_secrets_installed
        credentials  = File.expand_path(ENV['GOOGLE_APICLIENT_FILESTORAGE'] || '~/.google_drive_oauth2.json')
        file_storage = Google::APIClient::FileStorage.new(credentials)

        if file_storage.authorization
          @server_client.authorization = file_storage.authorization

        else
          flow = Google::APIClient::InstalledAppFlow.new(
            :client_id => $google_client_secrets_installed.client_id,
            :client_secret => $google_client_secrets_installed.client_secret,
            :scope => ['https://www.googleapis.com/auth/drive', 'email']
          )
          @server_client.authorization = flow.authorize(file_storage)
        end

      end

      @server_client
    end

    def web_client
      @web_client ||= (
        client = Google::APIClient.new(
          application_name: 'Driveshaft',
          application_version: Driveshaft::VERSION
        )
        client.authorization = $google_client_secrets_web.to_authorization.dup
        client.authorization.scope = 'https://www.googleapis.com/auth/drive email'

        # Find the correct URI to redirect to (OAuth settings can contain multiple)
        redirect_pattern = "^#{request.scheme}:\/\/#{request.host}"
        if request.port == {http: 80, https: 443}[request.scheme.to_sym]
          redirect_pattern += "(:#{request.port})?"
        else
          redirect_pattern += ":#{request.port}"
        end
        redirect_pattern = Regexp.new(redirect_pattern)

        redirect_uri = $google_client_secrets_web.redirect_uris.detect do |uri|
          uri.match(redirect_pattern)
        end
        client.authorization.redirect_uri = redirect_uri if redirect_uri

        client.authorization.update_token!(session)
        client)
    end

    get '/auth/authorize' do
      redirect web_client.authorization.authorization_uri(approval_prompt: :force).to_s
    end

    get '/auth/callback' do
      web_client.authorization.code = params['code']
      web_client.authorization.fetch_access_token!

      person = JSON.load(web_client.execute(
        api_method: web_client.discovered_api('plus', 'v1').people.get,
        parameters: {'userId' => 'me'}
      ).body)

      redirect('/auth/authorize') if $settings[:auth][:domain] && $settings[:auth][:domain] != person['domain']
      session[:email] = person['emails'].first['value']

      destination = session[:redirect]
      session[:redirect] = nil

      if destination && !destination.match(/^\/auth\//)
        redirect(destination)
      else
        redirect('/')
      end
    end

    get '/auth/logout' do
      session[:access_token] = session[:refresh_token] = session[:expires_in] = session[:issued_at] = session[:email] = nil
      @web_client = nil
      redirect('/')
    end

  end
end
