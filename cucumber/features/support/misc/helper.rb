# Helper methods
module Helper
  # explicit wait
  def wait_for
    Selenium::WebDriver::Wait.new(timeout: 10).until { yield }
  end

  def wait_for_displayed(find_by, path)
    if browser?
      $driver.switch_to.window($driver.window_handles.last)
      enter_app_iframe
      Selenium::WebDriver::Wait.new(timeout: 10).until { $driver.find_element(find_by.to_sym, path).displayed? }
    else
      Selenium::WebDriver::Wait.new(timeout: 10).until { $driver.find_element(find_by.to_sym, path).displayed? }
    end
  end

  def wait_for_not_displayed(find_by, path)
    try ||= 1
    Selenium::WebDriver::Wait.new(timeout: 30).until { $driver.find_elements(find_by.to_sym, path).empty? }
  rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
    $logger.error(e)
    sleep(1)
    retry if (try += 1) < 3
  end

  def try_times(times, callback, *args)
    begin
      retries ||= 0
      callback.call(*args)
    rescue Net::ReadTimeout, Selenium::WebDriver::Error::TimeoutError => e
      $logger.warn("#{retries + 1}. try: #{e}")
      retry if (retries += 1) < times
      return false
    end
    true
  end

  def current_page?(find_by, path)
    el = $driver.find_elements(find_by.to_sym, path)
    
    return false if el.empty?

    true
  end

  def method_on_element_present(element_path, method)
    sleep(1)
    element_array = $driver.find_elements(:class, element_path)
    method.call if element_array.any?
  end

  def method_on_element_not_present(element_path, method)
    sleep(1)
    element_array = $driver.find_elements(:class, element_path)
    method.call unless element_array.any?
  end

  def browser?
    ENV['PLATFORM_NAME'] == 'browser'
  end

  def android?
    ENV['PLATFORM_NAME'] == 'android'
  end

  def ios?
    ENV['PLATFORM_NAME'] == 'ios'
  end

  # There could be a case that there are more than one webview. Then switch by it's name
  def enter_webview
    return if browser?

    wait_for { $driver.available_contexts.count > 1 }
    begin
      try ||= 1
      $driver.set_context($driver.available_contexts.last)
      sleep(1)
    rescue StandardError => e
      $logger.warn("Error: #{e} \nCurrent context: #{$driver.current_context}")
      exit_webview
      sleep(3)
      retry if (try += 1) < 3
      raise e
    end
  end

  def exit_webview
    return if browser?

    wait_for { $driver.available_contexts.count > 1 }
    begin
      try ||= 1
      $driver.set_context($driver.available_contexts.first)
      sleep(1)
    rescue StandardError => e
      $logger.warn("Error: #{e} \nCurrent context: #{$driver.current_context}")
      enter_webview
      sleep(2)
      retry if (try += 1) < 3
      raise e
    end
  end

  def open_url(url)
    $logger.info("Navigating to url: #{url}")
    $driver.navigate.to(url)
    sleep(2)
    enter_app_iframe
  end

  def enter_app_iframe
    return unless ENV['IFRAME_APP'] == true
    $driver.switch_to.default_content
    wait_for { $driver.find_element(:class, $element_path['app-iframe']).displayed? }
    $driver.switch_to.frame $driver.find_element(:class, $element_path['app-iframe'])
  end

  def take_screenshot(filename)
    file_path = File.join(Dir.pwd, "screenshots/#{filename}.png")
    if browser?
      $driver.save_screenshot(file_path)
    else
      $driver.screenshot(file_path)
    end
    file_path
  end

  def embed_screenshot_in_report(file_path)
    encoded_img = Base64.encode64(File.open(file_path).read)
    embed("data:image/png;base64,#{encoded_img}", 'image/png')
  end

  def take_fail_shot
    failshot_file_name = "#{ENV['PLATFORM_NAME']}-failshot-#{timestamp}"
    failshot_path = take_screenshot(failshot_file_name)
    embed_screenshot_in_report(failshot_path)
    puts "Screenshot when test failed taken with the filename: #{failshot_file_name}.png"
    true
  end

  def after_step_screenshot
    shot_file_name = "#{ENV['PLATFORM_NAME']}-afterstep-#{timestamp}"
    shot_path = take_screenshot(shot_file_name)
    embed_screenshot_in_report(shot_path)
  end

  def take_element_screenshot(element, filename)
    $driver.element_screenshot(element, File.join(Dir.pwd, "screenshots/#{filename}.png"))
  end

  def get_background_position_y(element)
    element.css_value('background-position-y').to_i
  end

  def press_android_power_button
    $driver.press_keycode(26)
  end

  def press_android_enter_button
    $driver.press_keycode(66)
  end

  def quit_driver
    if browser?
      $driver.quit
    else
      $driver.driver_quit
    end
  end

  def random_number(digits)
    range = [*'0'..'9']
    Array.new(digits) { range.sample }.join
  end

  def random_string(from, to)
    range = [*'0'..'9', *'A'..'Z', *'a'..'z']
    number = Random.new.rand(from..to).to_i
    Array.new(number) { range.sample }.join
  end

  def random_email
    local_part = "test-#{SecureRandom.hex(Random.new.rand(1..5))}"
    domain = SecureRandom.hex(Random.new.rand(2..5)) + '.' + ('a'..'z').to_a.shuffle[1, 2].join
    local_part + '@' + domain
  end

  def number_from_string(amount_string)
    amount_string = amount_string.delete('.')
    amount_string = amount_string.delete(',')
    /\d+/.match(amount_string)[0].to_i
  end

  def try_close_ios_native_popups
    exit_webview
    begin
      $driver.find_element(:accessibility_id, 'Cancel').click
    rescue StandardError
    end
    begin
      $driver.find_element(:accessibility_id, 'OK').click
    rescue StandardError
    end
    enter_webview
  end

  def convert_order_word_to_number(order_word)
    order_word = order_word.strip
    case order_word
    when 'first'
      0
    when 'second'
      1
    when 'third'
      2
    when 'fourth'
      3
    when 'fifth'
      4
    when 'sixth'
      5
    when 'seventh'
      6
    when 'eighth'
      7
    when 'ninth'
      8
    else
      raise 'Not a recognized word for the order number'
    end
  end

  def letter?(char)
    char =~ /[[:alpha:]]/
  end

  def numeric?(char)
    char =~ /[[:digit:]]/
  end

  def upcase?(char)
    char =~ /[[:upper:]]/
  end

  def send_keys_ios_native(find_by, path, text)
    exit_webview
    begin
      try ||= 1
      return $driver.find_element(find_by.to_sym, path).send_keys(text)
    rescue StandardError => e
      $logger.warn("Error at send_keys_ios_native: #{e}")
      sleep(2)
      retry if (try += 1) < 5
    end
    enter_webview
  end

  def click_ios_native(find_by, path)
    exit_webview
    begin
      try ||= 1
      $driver.find_element(find_by.to_sym, path).click
    rescue StandardError => e
      $logger.warn("Error at click_ios_native: #{e}")
      sleep(2)
      retry if (try += 1) < 5
    end
    enter_webview
  end

  def press_keys_ios(input_text)
    $logger.info(input_text)
    letter_keypad = true
    input_text.split('').each do |char|
      begin
        try ||= 1
        # For letters
        if letter?(char)
          if letter_keypad == false
            $driver.find_element(:accessibility_id, 'more').click
            letter_keypad = true
          end
          if upcase?(char)
            $driver.find_element(:accessibility_id, 'shift').click
          end
          $driver.find_element(:accessibility_id, char).click
          $logger.info("Just typed #{char}")
          next
        # For number and special chars
        else
          if letter_keypad == true
            $driver.find_element(:accessibility_id, 'more').click
            letter_keypad = false
          end
          $driver.find_element(:accessibility_id, char).click
          $logger.info("Just typed #{char}")
        end
      rescue StandardError => e
        $logger.warn("Error at press_keys_ios: #{e}")
        sleep(2)
        retry if (try += 1) < 5
      end
    end
  end

  def timestamp
    Time.now.strftime('%d_%m_%Y__%H_%M_%S')
  end

  def js_console(command)
    # Avoiding >> unknown error: unhandled inspector error: {"code":-32000,"message":"Execution context was destroyed."}
    $driver.execute_script(command)
    sleep(1)
  rescue StandardError => e
    $logger.error(e)
  end
end
