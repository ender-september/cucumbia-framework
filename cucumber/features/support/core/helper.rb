# Helper methods
module Helper
  def quit_driver
    if MyEnv.browser?
      $browser.quit
    else
      driver_quit
    end
  end

  def element_locator(element_path)
    locator = if element_path.include?('//')
                :xpath
              elsif MyEnv.ios?
                :accessibility_id
              else
                :id
              end
    $driver.find_element(locator, element_path)
  end

  def current_page?(find_by, path)
    el = $driver.find_elements(find_by.to_sym, path)
    return false if el.empty?

    true
  end

  def execute_method_on_element_present(find_by, element_path, method)
    element_array = $driver.find_elements(find_by.to_sym, element_path)
    method.call if element_array.any?
  end

  def execute_method_on_element_not_present(find_by, element_path, method)
    element_array = $driver.find_elements(find_by.to_sym, element_path)
    method.call unless element_array.any?
  end

  def get_background_position_y(element)
    element.css_value('background-position-y').to_i
  end

  def open_url(url)
    $logger.info("Navigating to url: #{url}")
    $browser.navigate.to(url)
  end

  def string_between_markers(input_string, marker1, marker2)
    input_string[/#{Regexp.escape(marker1)}(.*?)#{Regexp.escape(marker2)}/m, 1]
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

  def timestamp
    Time.now.strftime('%d_%m_%Y__%H_%M_%S')
  end

  def js_console(command)
    # Avoiding >> unknown error: unhandled inspector error: {"code":-32000,"message":"Execution context was destroyed."}
    $browser.execute_script(command)
    sleep(1)
  rescue StandardError => e
    $logger.error(e)
  end
end
