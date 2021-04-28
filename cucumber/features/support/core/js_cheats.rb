# frozen_string_literal: true

# Console app manipulation methods
module JSCheats
  ### User data methods

  def clear_data_storage
    js_console('window.localStorage.clear()')
  end

  def reload_window
    js_console('window.location.reload()')
    sleep(3)
  end

  def login_with_local_storage_data(user_type)
    $logger.info("Logging in using local storage for user: #{user_type}")
    system_identifier = $users[user_type]["#{$app_abrv}-system-identifier"]
    device_secret = $users[user_type]["#{$app_abrv}-device-secret"]

    clear_data_storage
    js_console("window.localStorage.setItem('device_data', JSON.stringify({'SYSTEM_IDENTIFIER':'#{system_identifier}', 'USER_DEVICE_SECRET':'#{device_secret}'}))")
    reload_window
    LobbyPage.new($driver)
  end

  def logout_with_local_storage_data
    clear_data_storage
    reload_window
    WelcomePage.new($driver)
  end
end
