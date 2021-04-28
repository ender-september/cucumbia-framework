# Methods for OS
module OsLevelCommand
  def install_app
    system("adb install #{MyEnv.app_build_path}") if ENV['PLATFORM_NAME'] == 'android'
    system("ideviceinstaller -i #{MyEnv.app_build_path}") if ENV['PLATFORM_NAME'] == 'ios'
  end

  def app_installed?
    `adb shell pm list packages`.include?((ENV['APP_PACKAGE_NAME']).to_s) if ENV['PLATFORM_NAME'] == 'android'
    `ideviceinstaller -l`.include?((ENV['APP_PACKAGE_NAME']).to_s) if ENV['PLATFORM_NAME'] == 'ios'
  end

  def uninstall_app
    system("adb uninstall #{ENV['APP_PACKAGE_NAME']}") if ENV['PLATFORM_NAME'] == 'android'
    system("ideviceinstaller -U #{ENV['APP_PACKAGE_NAME']}") if ENV['PLATFORM_NAME'] == 'ios'
  end

  def launch_app
    $driver.launch_app
  end

  def quit_app
    $driver.terminate_app(ENV['APP_PACKAGE_NAME'])
  end

  def restart_app
    quit_app
    launch_app
  end
end
