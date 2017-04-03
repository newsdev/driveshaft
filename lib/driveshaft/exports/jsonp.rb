require 'csv'

module Driveshaft
  module Exports

    def self.jsonp(file, client)
      functions = []

      embedHtml   = client.execute(uri: file['embedLink']).body
      sheet_gids  = embedHtml.scan(/gid=(\d+)/).map(&:first)
      sheet_names = embedHtml.scan(/name: "([^"]+)"/).map(&:first)

      sheet_gids.each_with_index do |gid, idx|
        sheet_name = sheet_names[idx]
        next if sheet_name.match(/:hide$/)

        link     = file['exportLinks']['text/csv'] + "&gid=#{gid}"
        csv_data = client.execute(uri: link).body.force_encoding(Encoding::UTF_8)

        entries = []

        table = CSV.parse(csv_data, headers: true)
        table.each do |row|
          entry = row.to_h
          entry.keys.select { |k| k && k.match(/:hide$/) }.each { |k| entry.delete(k) }
          entries << entry
        end

        functions << "#{sheet_name}(#{JSON.dump(entries)});"
      end

      return {
        body: functions.join("\n"),
        content_type: 'application/javascript; charset=utf-8'
      }
    end

  end
end
