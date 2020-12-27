# Apstract class for page objects
class BasePage
  include Helper
  include JSCheats

  @@driver = nil

  def initialize(driver, find_by, unique_element_path)
    @@driver = driver
    unless browser?
      # Wait until server returns all capabilities of driver
      sleep(1) while @@driver.instance_variable_get(:@driver).nil?
    end
    # 1 second grace time when going to another page.
    # In unwanted cases when the same element being waited for exists on the previous page
    sleep(1)
    page_loaded?(find_by, unique_element_path)
  end

  def page_loaded?(find_by, element_path)
    loaded = try_times(3, method(:wait_for_displayed), find_by.to_sym, element_path)
    raise "Page not loaded! \n Element not found: #{element_path}" if loaded == false
  end
end
