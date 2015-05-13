require 'csv'

module Driveshaft
  module Exports

    def self.spreadsheet(file, client)
      data = {}

      embedHtml   = client.execute(uri: file['embedLink']).body
      sheet_gids  = embedHtml.scan(/gid=(\d+)/).map(&:first)
      sheet_names = embedHtml.scan(/name: "([^"]+)"/).map(&:first)

      sheet_gids.each_with_index do |gid, idx|
        sheet_name = sheet_names[idx]
        next if sheet_name.match(/:hide$/)

        link     = file['exportLinks']['text/csv'] + "&gid=#{gid}"
        csv_data = client.execute(uri: link).body

        puts "Sheet #{sheet_name}"
        data[sheet_name] = []

        table = CSV.parse(csv_data, headers: true)
        table.each do |row|
          entry = row.to_h
          entry.keys.select { |k| k && k.match(/:hide$/) }.each { |k| entry.delete(k) }
          data[sheet_name] << entry
        end
      end

      return {
        body: JSON.dump(data),
        content_type: 'application/json'
      }
    end

  end
end
