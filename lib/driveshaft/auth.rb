require 'google/apis/drive_v3'
require './lib/driveshaft/version'

# Reopen the App class and enable sessions / google authentication
module Driveshaft
  class App

    def drive_services
      scopes = ['https://www.googleapis.com/auth/drive']
      [
        application_default,
      ].compact
    end

    def application_default
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = Google::Auth.get_application_default(['https://www.googleapis.com/auth/drive'])
      service
    end

  end
end
