require 'google/apis/drive_v3'
require 'google/apis/plus_v1'
require './lib/driveshaft/version'

# Reopen the App class and enable sessions / google authentication
module Driveshaft
  class App

    # CLIENT = Google::APIClient.new(
    #   application_name: 'Driveshaft',
    #   application_version: Driveshaft::VERSION,
    #   force_encoding: true
    # )

    def drive_services
      scopes = ['https://www.googleapis.com/auth/drive']
      [
        application_default,
        web,
      ].compact
    end

    def application_default
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = Google::Auth.get_application_default(['https://www.googleapis.com/auth/drive'])
      service
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
