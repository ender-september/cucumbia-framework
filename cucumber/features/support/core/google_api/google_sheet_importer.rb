# Fetching data from google sheets
class GoogleSheetImporter
  attr_reader :sheet_key, :range, :worksheet, :service

  def initialize(sheet_key:, worksheet:, range: 'A:ZZ')
    @sheet_key = sheet_key
    @worksheet = worksheet
    @range = range
    @service = GoogleApiAuthorizer.new.google_api_service('sheets', 'api_key')
  end

  def rows
    @rows ||= load_rows.values
  end

  def load_rows
    @values = service.get_spreadsheet_values(sheet_key, [@worksheet, @range].join('!'))
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
