require 'rubygems'
require 'bundler'
Bundler.require

require 'rack'
require 'json'
require 'aws-sdk'
require 'google/api_client/client_secrets'

# Parse environmental variables

$settings = {
  index: {
    folder: ENV['DRIVESHAFT_SETTINGS_INDEX_FOLDER']
  },
  asset_host: (ENV['DRIVESHAFT_SETTINGS_ASSET_HOST'] || '/assets').sub(/\/$/, ''),
  max_versions: ENV['DRIVESHAFT_SETTINGS_MAX_VERSIONS'].to_i,
  session_secret: ENV['DRIVESHAFT_SETTINGS_SESSION_SECRET'] || 'secret'
}

if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_REGION']
  Aws.config.update(endpoint: ENV['AWS_ENDPOINT'] || 'https://s3.amazonaws.com')
  $s3           = Aws::S3::Client.new
  $s3_resources = Aws::S3::Resource.new
  $s3_presigner = Aws::S3::Presigner.new
end

require './lib/driveshaft'
require './lib/driveshaft/app'
require './lib/driveshaft/auth'

run Driveshaft::App.new
