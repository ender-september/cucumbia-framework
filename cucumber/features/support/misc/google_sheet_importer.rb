require 'google/apis/sheets_v4'

# Fetching data from google sheets
class GoogleSheetImporter
  attr_reader :key, :range, :worksheet, :service

  def initialize(key:, worksheet:, range: 'A:ZZ')
    @key = key
    @worksheet = worksheet
    @range = range
    @service = service
  end

  def service
    service = Google::Apis::SheetsV4::SheetsService.new
    service.authorization = authorizer
    service
  end

  def config_json
    StringIO.new(
      Base64.decode64(
        'key_for_sheets_api'
      )
    )
  end

  def authorizer
    scope = 'https://www.googleapis.com/auth/spreadsheets'
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: config_json, scope: scope
    )
  end

  def rows
    @rows ||= load_rows.values
  end

  def load_rows
    @values = service.get_spreadsheet_values(key, [@worksheet, @range].join('!'))
  end

  def headers
    @headers ||= rows.first
  end

  def list
    if @list.nil?
      @list = rows[1..-1]
      @list.reject! { |row| row.join('').strip.nil? } # remove empty rows
      @list.map! { |row| Hash[headers.zip(row)] }
    end
    @list
  end

  def hash
    list.map { |row| row.keep_if { |_k, v| !v.nil? } }
    array = []
    list.each do |row|
      temp = {}
      array << row.each do |k, v|
        temp[k.to_sym] = v
      end
      array << temp
    end
    array
  end
end
