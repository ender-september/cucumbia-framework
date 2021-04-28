# Wait methods
module Waiter
  # explicit wait
  def wait_for
    Selenium::WebDriver::Wait.new(timeout: 7).until { yield }
  end

  def wait_for_displayed(find_by, path)
    return wait_for { $driver.find_elements(find_by.to_sym, path).count > 0 } if MyEnv.ios?

    wait_for { $driver.find_element(find_by.to_sym, path).displayed? }
  end

  def wait_for_not_displayed(find_by, path)
    try ||= 0
    Selenium::WebDriver::Wait.new(timeout: 5).until { $driver.find_elements(find_by.to_sym, path).empty? }
  rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
    $logger.error(e)
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
end
