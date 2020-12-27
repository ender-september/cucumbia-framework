# Logic layer for tests
class BackofficeFlow
  include Helper

  def initialize(driver)
    self.driver = driver
  end

  def log_in
    driver.find_element(:id, $element_path['login-email-input']).send_keys($secrets['email'])
    driver.find_element(:id, $element_path['login-password-input']).send_keys($secrets['password'])
    driver.find_element(:class, $element_path['login-submit-button']).click
  end
end