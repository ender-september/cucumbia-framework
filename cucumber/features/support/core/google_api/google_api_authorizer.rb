require 'googleauth'
require 'google/apis/gmail_v1'
require 'google/apis/sheets_v4'
require 'googleauth/stores/file_token_store'
require 'httparty'

class GoogleApiAuthorizer
  attr_accessor :scope

  def google_api_service(service_type, authorization_type)
    case service_type
    when 'gmail'
      service = Google::Apis::GmailV1::GmailService.new
      @scope = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
    when 'sheets'
      service = Google::Apis::SheetsV4::SheetsService.new
      @scope = Google::Apis::SheetsV4::AUTH_SPREADSHEETS_READONLY
    else
      raise "Service type does not exist: #{service_type}"
    end

    case authorization_type
    when 'oauth2'
      service.authorization = authorize_oauth2
    when 'api_key'
      service.authorization = authorize_api_key
    else
      raise "Authorization type does not exist: #{authorization_type}"
    end

    service.client_options.application_name = MyEnv.project_id
    service
  end

  private

  # OAuth2 authorization

  def credentials_json
    File.join(__dir__, 'google_api_credentials.json')
  end

  def token_yaml
    File.join(__dir__, 'google_api_token.yml')
  end

  def authorize_oauth2
    credentials_hash = JSON.parse(File.read(credentials_json))
    credentials_hash['installed']['client_id'] = ENV['GOOGLE_CLIENT_ID']
    credentials_hash['installed']['client_secret'] = ENV['GOOGLE_CLIENT_SECRET']
    credentials_hash['installed']['project_id'] = MyEnv.project_id
    client = Google::Auth::ClientId.from_hash(credentials_hash)
    user_id = 'default'
    token_hash = { user_id => ENV['GOOGLE_API_TOKEN'] }
    File.open(token_yaml, 'w') { |file| file.write("#{user_id}:") } unless File.exist?(token_yaml)
    sleep(1) # Weird asynchronous stuff in the above line. Grace time for the write to finish.
    File.open(token_yaml, 'w') { |file| file.write(token_hash.to_yaml) } if YAML.load_file(token_yaml)[user_id].nil?
    token_store = Google::Auth::Stores::FileTokenStore.new file: token_yaml
    user_authorizer = Google::Auth::UserAuthorizer.new(client, scope, token_store)
    credentials = user_authorizer.get_credentials user_id

    if credentials.nil?
      url = user_authorizer.get_authorization_url base_url: 'urn:ietf:wg:oauth:2.0:oob'
      puts "Open this url: #{url} and authenticate"
      puts 'Copy the code, paste the code here and press ENTER'
      code = gets.chomp

      credentials = user_authorizer.get_and_store_credentials_from_code(
        user_id: user_id, code: code, base_url: 'urn:ietf:wg:oauth:2.0:oob'
      )
      puts "Open #{token_yaml} and set the value as GOOGLE_API_TOKEN variable in .env. Do not commit the yaml!"
      puts 'Press ENTER to continue'
      gets.chomp
    end

    refresh_access_token(credentials) if credentials.expires_at < Time.now
    credentials
  end

  def refresh_access_token(credentials)
    options = {
      body: {
        client_id: credentials.client_id,
        client_secret: credentials.client_secret,
        refresh_token: credentials.refresh_token,
        grant_type: 'refresh_token'
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    }
    response = HTTParty.post('https://accounts.google.com/o/oauth2/token', options)

    if response.code == 200
      credentials.access_token = response.parsed_response['access_token']
      credentials.expires_at = DateTime.now + response.parsed_response['expires_in']
      credentials
    else
      $logger.error('Unable to refresh google_oauth2 authentication token.')
      $logger.error("Refresh token response body: #{response.body}")
      raise
    end
  end

  # Api key authorization

  def api_key
    StringIO.new(
      Base64.decode64(
        ENV['GOOGLE_API_KEY']
      )
    )
  end

  def authorize_api_key
    Google::Auth::ServiceAccountCredentials.make_creds(
      json_key_io: api_key, scope: scope
    )
  end
end
