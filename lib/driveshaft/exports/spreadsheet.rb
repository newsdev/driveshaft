require 'csv'
require 'google/apis/sheets_v4'

module Driveshaft
  module Exports

    def self.spreadsheet(file, drive_service)
      data = {}

      sheets_service = Google::Apis::SheetsV4::SheetsService.new
      sheets_service.authorization = drive_service.authorization
      sheets = sheets_service.get_spreadsheet(file.id, fields: 'sheets.properties.sheetId,sheets.properties.title').sheets

      sheets.each do |sheet|
        sheet_name = sheet.properties.title
        next if sheet_name.match(/:hide$/)

        # There is currently no way to export data from the non-first sheet using the V3 Drive API.
        # https://issuetracker.google.com/issues/36760272
        # csv_data = drive_service.export_file(file.id, 'text/csv')
        csv_data = drive_service.http(:get, "https://docs.google.com/spreadsheets/export?id=#{file.id}&exportFormat=csv&gid=#{sheet.properties.sheet_id}").force_encoding(Encoding::UTF_8)

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
        content_type: 'application/json; charset=utf-8'
      }
    end

  end
end
