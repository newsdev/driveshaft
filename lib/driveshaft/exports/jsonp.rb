require 'csv'
require 'google/apis/sheets_v4'

module Driveshaft
  module Exports

    def self.jsonp(file, drive_service)
      functions = []

      sheets_service = Google::Apis::SheetsV4::SheetsService.new
      sheets_service.authorization = drive_service.authorization
      sheets = sheets_service.get_spreadsheet(file.id, fields: 'sheets.properties.sheetId,sheets.properties.title').sheets

      sheets.each do |sheet|
        sheet_name = sheet.properties.title
        next if sheet_name.match(/:hide$/)

        csv_data = drive_service.http(:get, "https://docs.google.com/spreadsheets/export?id=#{file.id}&exportFormat=csv&gid=#{sheet.properties.sheet_id}").force_encoding(Encoding::UTF_8)

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
