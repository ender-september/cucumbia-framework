# Logic layer for tests
class Flow
  include Helper
  attr_accessor :logged_users_email, :logged_users_name, :login_times

  def initialize(driver)
    self.driver = driver
    self.logged_users_email = []
    self.logged_users_name = []
    self.login_times = 1
  end

  def log_in(type)
    case type
    when /guest user/
      login_as_guest
    when /registered user/
      self.user_type = 'registered'
      login_with_local_storage_data(user_type)
      # Full flow
      # login_as_registered_user($users[user_type]['email'])
    when /new user/
      self.user_type = 'new'
      login_as_new_user(random_email)
    else
      raise 'Provided user type not recognized'
    end

    Account.type = user_type
    if user_type.nil?
      Account.name = 'Guest'
      Account.email = ''
      Account.level = 1
      Account.account_status = 'guest'
      Account.active_friends_number = 0
    elsif user_type == 'new'
      Account.name = user_name
      Account.email = user_email
      Account.level = 1
      Account.account_status = 'registered'
      Account.active_friends_number = 0
    else
      Account.name = $users[user_type]['name']
      Account.email = $users[user_type]['email']
      Account.level = @lobby_page.user_level
      Account.account_status = 'registered'
      Account.active_friends_number = 0
    end

    # Record all users that have logged in within a test run
    unless logged_users_email.include?(Account.email)
      logged_users_email.push(Account.email)
    end
    unless logged_users_email.include?(Account.name)
      logged_users_name.push(Account.name)
    end

    self.login_times += 1

    $logger.info("Logged in successfully for #{type}!")
    @lobby_page
  end

  private

  attr_accessor :driver
  attr_accessor :user_type, :user_email, :user_name

  def login_as_guest
    @welcome_page = WelcomePage.new(driver)
    @lobby_page = @welcome_page.click_signin_as_guest_button
    @lobby_page
  end

  def login_as_new_user(user_email)
    self.user_email = user_email
    self.user_name = random_string(2, 12) unless ios?
    self.user_name = random_string(2, 2) if ios?
    @welcome_page = WelcomePage.new(driver)
    @lobby_page = @welcome_page.click_login_button
    @lobby_page
  end

  def fetch_all_users_storage_data
    $users.each_key do |user_type|
      login_as_registered_user($users[user_type]['email'])
      data = JSON.parse(driver.local_storage.fetch('device_data'))
      $logger.info("#{user_type} - SYSTEM_IDENTIFIER: #{data['SYSTEM_IDENTIFIER']}, USER_DEVICE_SECRET: #{data['USER_DEVICE_SECRET']}")
      logout_with_local_storage_data
    end
  end
end
