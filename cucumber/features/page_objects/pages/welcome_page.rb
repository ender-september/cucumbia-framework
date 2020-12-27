# WelcomePage displayed when the app is opened the first time after installing
class WelcomePage < BasePage
  def initialize(driver)
    super(driver, :class, login_logo_path)
  end

  def self.unique_element
    $element_path['login-logo']
  end

  def login_logo_path
    $element_path['login-logo']
  end

  def signin_as_guest_button_path
    $element_path['signin-as-guest-button']
  end

  def signin_as_guest_button
    @@driver.find_element(:class, signin_as_guest_button_path)
  end

  def click_signin_as_guest_button
    signin_as_guest_button.click
    LobbyPage.new(@@driver)
  end
end
