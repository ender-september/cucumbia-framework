# Fetching data from Gmail
require File.join(__dir__, '../helper.rb')

class GmailImporter
  include Helper

  attr_reader :service

  def initialize
    @service = GoogleApiAuthorizer.new.google_api_service('gmail', 'oauth2')
  end

  def app_verification_url(user_email)
    email_id = user_mail_id(user_email)
    body = email_content(email_id).payload.to_h[:parts].to_s
    app_verification_url = string_between_markers(body, 'Verify app\\r\\n<', '>')
  end

  def email_content(id)
    email = service.get_user_message('me', id) # Class: Google::Apis::GmailV1::MessagePart
  end

  def user_mail_id(user_email)
    i = 0
    # Loop until the email is received
    loop do
      email_list = service.list_user_messages('me', max_results: 1) # Class: Google::Apis::GmailV1::ListMessagesResponse
      last_email = email_list.messages[0] # Class: Google::Apis::GmailV1::Message
      send_to = email_content(last_email.id).payload.headers[0].value

      break if send_to == user_email
      raise 'Did not find the email' if i == 10

      sleep(2)
      i += 1
    end
    last_email.id
  end
end
