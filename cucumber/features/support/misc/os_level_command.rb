require 'appium_lib'
require 'selenium-webdriver'

# Methods for OS
module OsLevelCommand
  @app_build_path = nil

  # Check if build is on local or the web (either 'uri' is nil or a link)
  def app_build_path(uri_path)
    # if uri is a web URL
    if uri_path.include?('//')
      @app_build_path = uri_path
      return @app_build_path
    end

    # Start from HOME unless the app build is in the testing project in a dir called "resources"
    uri_path = File.join(ENV['HOME'], uri_path.to_s) unless uri_path == 'resources'

    extension = ENV['PLATFORM_NAME'] == 'ios' ? 'ipa' : 'apk'
    extension = 'app' if MyEnv.true?('IOS_SIMULATOR')

    app_path = File.join(File.expand_path('..', Dir.pwd), "#{uri_path}/#{ENV['APP']}")
    @app_build_path = "#{app_path}.#{extension}"
  end

  def install_the_app
    if ENV['PLATFORM_NAME'] == 'android'
      system("adb install #{@app_build_path}")
    end
    if ENV['PLATFORM_NAME'] == 'ios'
      system("ideviceinstaller -i #{@app_build_path}")
    end
  end

  def app_installed?
    if ENV['PLATFORM_NAME'] == 'android'
      `adb shell pm list packages`.include?("#{ENV['APP_PACKAGE_NAME']}")
    end
    if ENV['PLATFORM_NAME'] == 'ios'
      `ideviceinstaller -l`.include?("#{ENV['APP_PACKAGE_NAME']}")
    end
  end

  def uninstall_the_app
    return true unless app_installed?

    if ENV['PLATFORM_NAME'] == 'android'
      system("adb uninstall #{ENV['APP_PACKAGE_NAME']}")
    end
    if ENV['PLATFORM_NAME'] == 'ios'
      system("ideviceinstaller -U #{ENV['APP_PACKAGE_NAME']}")
    end
  end

  def add_install_app_config
    uninstall_the_app    
    MyEnv.append_appium_config_file('app', @app_build_path)
    MyEnv.append_appium_config_file('fullReset', ENV['FULL_RESET']) unless ENV['FULL_RESET'].nil?
  end

  def launch_app
    $driver.launch_app
  end

  def quit_app
    $driver.terminate_app("#{config[app_package_name]}")
  end

  def restart_app
    quit_app
    launch_app
  end
end
