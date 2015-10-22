require 'google/api_client'
require './lib/driveshaft/version'

# Reopen the App class and enable sessions / google authentication
module Driveshaft
  class App

    CLIENT = Google::APIClient.new(
      application_name: 'Driveshaft',
      application_version: Driveshaft::VERSION,
      force_encoding: true
    )

    def clients
      [
        key_client,
        service_account_client,
        installed_client,
        web_client
      ].compact.select { |client| client.key || client.authorization.access_token }
    rescue Exception => e
      flash[:error] = "Error authenticating with the Google Drive API. #{e.message}"
    end

    def service_account_client
      return nil unless $google_service_account

      @service_account_client ||= (
        client = CLIENT.dup
        key = Google::APIClient::KeyUtils.load_from_pem($google_service_account['private_key'], 'notasecret')

        client.authorization = Signet::OAuth2::Client.new(
          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
          audience: 'https://accounts.google.com/o/oauth2/token',
          scope: 'https://www.googleapis.com/auth/drive',
          issuer: $google_service_account['client_email'],
          signing_key: key
        )
        client.authorization.fetch_access_token!
        client)
    end

    def installed_client
      return nil unless $google_client_secrets_installed

      @installed_client ||= (
        client = CLIENT.dup
        file_storage = Google::APIClient::FileStorage.new($google_client_secrets_installed_cache)

        if file_storage.authorization
          client.authorization = file_storage.authorization
        else
          flow = Google::APIClient::InstalledAppFlow.new(
            :client_id => $google_client_secrets_installed.client_id,
            :client_secret => $google_client_secrets_installed.client_secret,
            :scope => ['https://www.googleapis.com/auth/drive', 'email']
          )
          client.authorization = flow.authorize(file_storage)
        end

        client)
    end

    def web_client
      return nil unless $google_client_secrets_web

      @web_client ||= (
        client = CLIENT.dup
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

    def key_client
      return nil unless $google_client_key

      # Set authorization to nil tell APIClient to rely on the API Key instead
      client = CLIENT.dup
      client.authorization = nil
      client.key = $google_client_key
      client
    end

    if $google_client_secrets_web || $google_client_secrets_installed
      # Here, `application_client` stands in for either the web application or
      # installed / native application client, as only one can be active.

      def application_client
        installed_client || web_client
      rescue Exception => e
        flash[:error] = "Error authenticating with the Google Drive API. #{e.message}"
      end

      if $settings[:auth][:required]
        before do
          if !application_client.authorization.access_token && !request.path_info.match(/^\/auth\//)
            redirect('/auth/authorize')
          end
        end
      end

      after do
        return unless application_client.authorization.access_token

        # Get the user's email address and redirect if it doesn't match the
        # auth domain setting.
        session[:email] ||= (
          person = JSON.load(application_client.execute(
            api_method: plus_api.people.get,
            parameters: {'userId' => 'me'}
          ).body)

          redirect('/auth/authorize') if $settings[:auth][:domain] && $settings[:auth][:domain] != person['domain']

          begin
            person['emails'].first['value']
          rescue Exception => e
            flash[:error] = "Authentication Error: Google OAuth2 token did not include user's email. Make sure your Google Project has enabled access to the Google+ API."
            return
          end
        )

        session[:access_token] = application_client.authorization.access_token
        session[:refresh_token] = application_client.authorization.refresh_token
        session[:expires_in] = application_client.authorization.expires_in
        session[:issued_at] = application_client.authorization.issued_at
      end

      get '/auth/authorize' do
        redirect application_client.authorization.authorization_uri(approval_prompt: :force).to_s
      end

      get '/auth/callback' do
        application_client.authorization.code = params['code']
        application_client.authorization.fetch_access_token!

        destination = session[:redirect]
        session[:redirect] = nil

        if destination && !destination.match(/^\/auth\//)
          redirect(destination)
        else
          redirect('/index')
        end
      end

      get '/auth/logout' do
        session[:access_token] = session[:refresh_token] = session[:expires_in] = session[:issued_at] = session[:email] = nil
        @web_client = @installed_client = nil
        File.delete($google_client_secrets_installed_cache) if File.exist?($google_client_secrets_installed_cache)
        redirect('/index')
      end

    end

  end
end
