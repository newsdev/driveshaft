require 'json'
require 'date'

require 'sinatra/base'
require 'sinatra/content_for'
require 'sinatra/multi_route'
require 'rack-flash'

require 'google/apis/drive_v3'
require 'google/apis/plus_v1'

require './lib/driveshaft/exports'
require './lib/driveshaft/version'

module Driveshaft
  class App < Sinatra::Base
    helpers Sinatra::ContentFor
    register Sinatra::MultiRoute

    set :protection, :except => :path_traversal

    use Rack::Session::Cookie,
        :key => 'rack.session',
        :path => '/',
        :expire_after => 14400,
        :secret => $settings[:session_secret]
    use Rack::Flash, :sweep => true

    configure do
      enable :logging
    end

    get '/' do
      redirect('/index')
    end

    get '/healthcheck' do
      status 200
    end

    # Homepage is listed under "index" to allow accessing versions appended to
    # the path, without creating ambiguity with the "/:file" route.
    get '/index/?*' do
      if params[:splat] && params[:splat].first.match(/\.json$/)
        if (version = params[:splat].first[1..-5]).length > 0
          @files = get_settings(version)
          @title = version
        else
          @files = get_settings
        end

        content_type :json
        return @files.values.to_json

      else
        return erb :index
      end
    end

    get '/:file/?' do
      get_file!
      @destinations.map! do |destination|
        bucket, key = destination
        begin
          object = $s3_resources.bucket(destination[:bucket]).object(destination[:key])
          object.etag
        rescue Aws::S3::Errors::NotFound, Aws::S3::Errors::Forbidden
          object = nil
        rescue
          object = nil
        end

        destination.merge({
          object: object,
          etag: (object.etag[1..-2] unless object.nil?)
        })
      end

      return erb :file
    end

    get '/:file/versions/*' do
      get_file!
      bucket, key = parse_destination(params[:splat].first)

      objects = get_versions(bucket, key).reverse

      etags = {}
      versions = []
      objects.each do |object|
        etag = object.etag[1..-2]
        versions << {
          bucket: bucket,
          key: object.key,
          url: "http://#{bucket}.s3.amazonaws.com/#{object.key}",
          presigned_url: ($s3_presigner.presigned_url(:get_object, bucket: bucket, key: object.key) rescue nil),
          etag: etag,

          timestamp: object.key.match(/(\d{8}-\d{6}).\w+$/)[1],
          copy: etags.key?(etag),
          display: Time.strptime(File.basename(object.key).sub(/\.json$/, '').match(/(\d{8}-\d{6})$/)[1] + " +0000", "%Y%m%d-%H%M%S %Z").getlocal.strftime("%a %b %d %I:%M %p %Z")
        }
        etags[etag] = 1
      end

      content_type :json
      return versions.to_json
    end

    get '/:file/edit/?' do
      get_file!
      redirect(@file.web_view_link)
    end

    get '/:file/download/?' do
      get_file!
      begin
        export = Driveshaft::Exports.export(@file, @export_format, *drive_services)
      rescue Exception => e
        status 200
        puts e.message
        puts e.backtrace
        export = {
          content_type: 'application/json; charset=utf-8',
          body: JSON.dump({
            "message" => "Error converting #{@file.name || @file.id} into #{@export_format}. (#{e.message})",
            "backtrace" => e.backtrace.join("\n"),
            "status" => "error"
          })
        }
      end

      content_type export[:content_type]
      export[:body]
    end

    route :get, :post, '/:file/refresh/?.?:format?' do
      get_file!

      if !@destinations || @destinations.length == 0
        flash[:error] = "No destinations specified."
      else
        @destinations.each do |destination|
          refresh!(destination[:bucket], destination[:key]) unless @file['error']
        end
      end

      if request.request_method == "POST"
        content_type :json
        return {
          status: flash[:error] ? 'error' : 'success',
          error: flash[:error]
        }.to_json
      else
        redirect back
      end
    end

    route :get, :post, '/:file/refresh/*' do
      get_file!
      bucket, key = parse_destination(params[:splat].first)
      refresh!(bucket, key) unless @file.nil?

      if request.request_method == "POST"
        content_type :json
        return {
          status: flash[:error] ? 'error' : 'success',
          error: flash[:error]
        }.to_json
      else
        redirect back
      end
    end

    route :get, :post, '/:file/restore/*' do
      get_file!
      bucket, key = parse_destination(params[:splat].first)

      timestamp = key.match(/(\d{8}-\d{6}).\w+$/)[1]
      key.gsub!(/-#{timestamp}/, '')

      restore!(bucket, key, timestamp) unless @file.nil?

      if request.request_method == "POST"
        content_type :json
        return {
          status: flash[:error] ? 'error' : 'success',
          error: flash[:error]
        }.to_json
      else
        redirect back
      end
    end

    private

    def back
      params[:redirect] || request.referer
    end

    def get_file!
      begin
        # Our before filter, variable set up
        @key  = params[:file]
        @file = nil

        drive_services.each_with_index do |drive_service, idx|
          begin
            @file = drive_service.get_file(@key,
              supports_team_drives: true,
              fields: 'id, name, mimeType, webViewLink'
            )
          rescue Google::Apis::ClientError => e
            # TK
            puts e.message
            puts e.backtrace
          else
            break
          end
        end

        file_config = get_settings[@key] || {}

        # Allow overriding default file config with querystring parameters
        default_export_format = file_config['format'] || (Driveshaft::Exports.default_format_for(@file) if @file)

        @destinations = get_destinations(params) || file_config['destinations'] || []
        @export_format = params[:format] || default_export_format

        if @file.nil?
          flash[:error] = "No clients able to access file #{@key}"
        elsif !file_config.empty? && (file_config['destinations'] != @destinations || default_export_format != @export_format)
          flash[:info] = "You are using settings configured in the URL. Automated publishing may use a different format or destination. <a href='https://docs.google.com/a/nytimes.com/spreadsheets/d/#{$settings[:index][:key]}/edit#gid=0'>Update or add</a> this file's configuration to make these settings persist."
        end

      rescue Exception => e
        flash[:error] = "Error while attempting to access file #{params[:file]}. #{e.message}"
        puts e.message
        puts e.backtrace
      end

      if @file.nil? && request.request_method != "POST"
        redirect back
      end
    end

    # Can we make this work for any user's individual drive folder?
    def get_settings(version = nil) # TKTKTK
      return {} unless $settings[:index][:key]

      begin
        bucket, key = parse_destination($settings[:index][:destination])
        key = key.sub(/\.json$/, "-#{version}.json") if version
        settings = JSON.load($s3_resources.bucket(bucket).object(key).get.body).values.first
      rescue Exception => e
        puts e.message
        puts e.backtrace
        settings = nil
      end

      # Bootstrap the settings json
      settings ||= [{'key' => $settings[:index][:key], 'publish' => $settings[:index][:destination]}]

      files = Hash[*settings.map do |row|
        file_config = row.dup
        file_config['destinations'] = get_destinations(file_config) || []
        [row['key'], file_config]
      end.flatten]

      files
    end

    # File configuration can have multiple destinations on S3, by specifying
    # keys that begin with "publish". This method converts the values for all
    # keys into an array of destination objects.
    def get_destinations(file_config)
      destinations = file_config.keys.sort.select { |k| k.match(/^publish/) }.map { |k| file_config[k] if file_config[k] && file_config[k].length > 0 }.compact
      destinations.map! do |destination|
        bucket, key = parse_destination(destination)
        return nil unless bucket && key

        {
          bucket: bucket,
          key: key,
          format: file_config['format'],
          url: "http://#{bucket}.s3.amazonaws.com/#{key}",
          presigned_url: ($s3_presigner.presigned_url(:get_object, bucket: bucket, key: key) rescue nil)
        }
      end
      destinations.compact!
      destinations if destinations.length > 0
    end

    def get_versions(bucket, key)
      directory = key.sub(/(?<!\/)([^\/]+$)/, '')
      basename  = File.basename(key).sub(/\.\w+$/, '')

      objects = $s3.list_objects(bucket: bucket, prefix: directory, delimiter: '/', encoding_type: nil).contents
      objects.select! { |object| object.key.match(/(?:^|\/)#{basename}-\d{8}-\d{6}\.\w+$/) }
      objects
    end

    def refresh!(bucket, key)
      puts "Generating json for file '#{@file.name}'"

      begin
        export = Driveshaft::Exports.export(@file, @export_format, *drive_services)
        unless export[:body]
          flash[:error] = "No output found."
        end
      rescue Exception => e
        flash[:error] = "Error converting #{@file.name || @file.id} into #{@export_format}. (#{e.message})"
        puts e.message
        puts e.backtrace
      end

      puts "Writing json file to #{bucket}/#{key}"
      objects = [
        $s3_resources.bucket(bucket).object(key),
        $s3_resources.bucket(bucket).object(key.sub(/(\.\w+)$/, "-#{Time.now.utc.strftime("%Y%m%d-%H%M%S")}\\1"))
      ]

      put_options = {acl: 'public-read'}.merge(export)
      objects.each do |object|
        object.put(put_options)
      end

      # Prune stored versions to a max number
      if $settings[:max_versions] > 0
        expired = get_versions(bucket, key).reverse[$settings[:max_versions]..-1] || []
        expired.each do |version|
          $s3_resources.bucket(bucket).object(version.key).delete
        end
      end

      puts "File written to #{bucket}/#{key}"
    rescue Exception => e
      flash[:error] = "Error writing to #{bucket}/#{key}. #{e.message}"
      puts e.message
      puts e.backtrace
    end

    def restore!(bucket, key, timestamp)
      timestamped_key = key.sub(/(?=\.\w+$)/, "-#{timestamp}")
      $s3_resources.bucket(bucket).object(key).copy_from({
        copy_source: File.join(*[bucket, timestamped_key].compact)
      })
    end

    # Converts a URL-style S3 address into the component bucket and key
    # s3://BUCKET/KEY
    # http://BUCKET/KEY
    # http://BUCKET.s3.amazonaws.com/KEY
    # http://s3.amazonaws.com/BUCKET/KEY
    def parse_destination(destination)
      components = destination.match(/(?:(?:https?|s3):\/{1,2})?(?:(?:\.?s3(?:\.|-)[\-\w]*\.?amazonaws\.com)|([\.\-_\w]+?)?)(?:\.?s3(?:\.|-)[\-\w]*\.?amazonaws\.com)?\/(?:([\.\-_\w]*?)\/)?(.+)/).to_a.compact
      [components[1], components[2..-1].join('/')]
    rescue Exception => e
      puts "Error parsing S3 destination from '#{destination}'."
      puts e.message
      puts e.backtrace
      nil
    end

  end
end
