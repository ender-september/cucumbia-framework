require 'net/http'

# Mailtrap API requests
class MailtrapRequester
  def email_code(email_address)
    email = email_content(email_address)
    %r{ app: (.*?)</p>}.match(email.body)[1]
  end

  def email_link(email_address)
    email = email_content(email_address)
    "https:#{/https:(.*?)\"/.match(email.body)[1]}"
  end

  def delete_email(message_id)
    send_request('delete', "/#{message_id}")
  end

  def latest_email_id
    res_all_emails = send_request('get', '')
    /\"id\":(.*?),/.match(res_all_emails.body)[1]
  end

  def send_request(method, uri_path)
    inbox_id = '123'
    api_token = 'api_token'
    uri = URI("https://mailtrap.io/api/v1/inboxes/#{inbox_id}/messages" + uri_path)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    params = { api_token: api_token }
    uri.query = URI.encode_www_form(params)
    case method
    when 'get'
      res = http.request(Net::HTTP::Get.new(uri.request_uri))
    when 'delete'
      res = http.request(Net::HTTP::Delete.new(uri.request_uri))
    end
    case res
    when Net::HTTPSuccess, Net::HTTPRedirection
      res
    else
      raise res.value
    end
  end

  private

  def email_content(sent_email_address)
    message_id = latest_email_id

    received_email_content = send_request('get', "/#{message_id}/body.raw")

    # Is the email received
    check_address_match_latest_email(sent_email_address, received_email_content)

    # Cleanup - delete the email from mailtrap
    delete_email(message_id)

    received_email_content
  end

  def check_address_match_latest_email(sender, content)
    i = 0
    # Loop until the email is received
    loop do
      receiver = /To: (.*?)$/.match(content.body)[1]
      break if sender == receiver

      if i == 15
        raise "Latest received email address in mailtrap inbox does not match the user's:
         \nSent to: #{sender} \nReceived: #{receiver}"
      end

      sleep(5)
      i += 1
    end
  end
end
