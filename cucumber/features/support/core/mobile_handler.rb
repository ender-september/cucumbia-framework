# Mobile device specific methods
module MobileHandler
  def press_android_power_button
    $driver.press_keycode(26)
  end

  def press_android_enter_button
    $driver.press_keycode(66)
  end

  def try_close_ios_native_popups
    begin
      $driver.find_element(:accessibility_id, 'Cancel').click
    rescue StandardError
    end
    begin
      $driver.find_element(:accessibility_id, 'OK').click
    rescue StandardError
    end
  end

  def send_keys_ios_native(find_by, path, text)
    try ||= 1
    $driver.find_element(find_by.to_sym, path).send_keys(text)
  rescue StandardError => e
    $logger.warn("Error at send_keys_ios_native: #{e}")
    sleep(2)
    retry if (try += 1) < 5
  end

  def click_ios_native(find_by, path)
    try ||= 1
    $driver.find_element(find_by.to_sym, path).click
  rescue StandardError => e
    $logger.warn("Error at click_ios_native: #{e}")
    sleep(2)
    retry if (try += 1) < 5
  end

  def press_keys_ios(input_text)
    $logger.info(input_text)
    letter_keypad = true
    input_text.split('').each do |char|
      try ||= 1
      # For letters
      if letter?(char)
        if letter_keypad == false
          $driver.find_element(:accessibility_id, 'more').click
          letter_keypad = true
        end
        $driver.find_element(:accessibility_id, 'shift').click if upcase?(char)
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
