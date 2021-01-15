require 'appium_lib'
require 'cucumber'
require 'selenium-webdriver'
require 'yaml'
require 'logger'
require 'rspec/expectations'
require 'pry'
require 'securerandom'
require 'tracer'
require 'base64'
Dir[File.join(__dir__, 'misc', '*.rb')].sort.each { |file| require file }

class MyEnv
  
  TRUTHY_VALUES = %w(t true yes y 1).freeze
  FALSEY_VALUES = %w(f false n no 0).freeze

  def self.true?(value)
    return false if ENV[value].nil?
    return false if FALSEY_VALUES.include?(ENV[value].to_s.downcase)
    return true if TRUTHY_VALUES.include?(ENV[value].to_s.downcase)

    raise "Invalid value '#{value}' for boolean casting!"
  end

  def self.appium_config_file
    File.join(File.dirname(__FILE__), "appium_#{ENV['PLATFORM_NAME']}_caps.txt")
  end

end

# Android specific configurations
class AndroidWorld
  extend OsLevelCommand

  def caps
    puts 'Running on Android...'
    Appium.load_appium_txt file: MyEnv.appium_config_file
  end

  def install_app
    app_build_path(ENV['APP_BUILD_URL'])
    add_install_app_config
  end

  def app_bundle
    return if File.foreach(MyEnv.appium_config_file).grep(/appPackage/).any?

    File.open(MyEnv.appium_config_file, 'a') do |f|
      f.write "\nappPackage=\"#{ENV['APP_PACKAGE_NAME']}\""
      f.write "\nappActivity=\"#{ENV['APP_PACKAGE_NAME']}.MainActivity\""
    end
  end

  def unlock_device(unlock_type, unlock_key)
    return if File.foreach(MyEnv.appium_config_file).grep(/unlockType/).any?

    File.open(MyEnv.appium_config_file, 'a') do |f|
      f.write "\nunlockType=\"#{unlock_type}\""
      f.write "\nunlockKey=\"#{unlock_key}\""
    end
  end
end

# iOS specific configurations
class IosWorld
  extend OsLevelCommand

  def caps
    puts 'Running on iOS...'
    Appium.load_appium_txt file: MyEnv.appium_config_file
  end

  def install_app
    app_build_path(ENV['APP_BUILD_URL'])
    add_install_app_config
  end

  def ios_device_specific_config
    if MyEnv.true?('IOS_SIMULATOR')
      device_name = 'iPhone Simulator'
      device_version = ENV['DEVICE_VERSION'] || '14.3'
    else
      device_name = `ideviceinfo | grep -i DeviceName`.sub! 'DeviceName: ', ''
      
      if device_name == nil
        raise 'iOS device not found. Check connection... Tip: You can use the command: ideviceinfo'
      end
      
      device_name = device_name.strip
      device_version = `ideviceinfo | grep -i ProductVersion`.sub! 'ProductVersion: ', ''
      device_version = /^\d+\.[1-9]\d*/.match(device_version)
    end

    $logger.info("Device name: #{device_name}")
    $logger.info("Device version: #{device_version}")
    
    return if File.foreach(MyEnv.appium_config_file).grep(/deviceName/).any?

    File.open(MyEnv.appium_config_file, 'a') do |f|
      f.write "\ndeviceName=\"#{device_name}\""
      f.write "\nplatformVersion=\"#{device_version}\""
    end
  end

  def app_bundle
    return if File.foreach(MyEnv.appium_config_file).grep(/bundleId/).any?
    
    File.open(MyEnv.appium_config_file, 'a') do |f|
      f.write "\nbundleId=\"#{ENV['APP_PACKAGE_NAME']}\""
    end
  end
end

# Chrome specific configurations
class ChromeWorld
  def caps
    capabilities_config = {
      platform: :MAC
    }

    if MyEnv.true?('HEADLESS_BROWSER')
      capabilities_config[:chromeOptions] = { 'args' => ['headless'] }
    end

    Selenium::WebDriver::Remote::Capabilities.send(:chrome, capabilities_config)
  end

  def server_url
    ENV['SELENIUM_HUB_URL'] || 'http://127.0.0.1:4444/wd/hub'
  end
end

# Firefox specific configurations
class FirefoxWorld
  def caps
    capabilities_config = {
      platform: :MAC
    }
    Selenium::WebDriver::Remote::Capabilities.send(:firefox, capabilities_config)
  end

  def server_url
    ENV['SELENIUM_HUB_URL'] || 'http://127.0.0.1:4444/wd/hub'
  end
end

# Safari specific configurations
class SafariWorld
  def caps
    capabilities_config = {
      platform: :MAC
    }
    Selenium::WebDriver::Remote::Capabilities.send(:safari, capabilities_config)
  end

  def server_url
    ENV['SELENIUM_HUB_URL'] || 'http://127.0.0.1:4444/wd/hub'
  end
end

################
### Script start
################

# Initialize the logger and create log file
$logger = LoggerBuilder.new('logfile.log')

# Create directory for screenshots
Dir.mkdir('screenshots') unless Dir.exist?('screenshots')

### App specific setup
element_path_file = File.join(Dir.pwd, 'features/support/misc/element_path.yaml')
$element_path = ElementRegistry.new(element_path_file).element_path_file_hashmap

# Load property files
$users = YAML.load_file File.join(Dir.pwd, 'features/support/misc/users.yaml')

if File.exist?(File.join('~/', 'secret.yaml'))
  $secrets = YAML.load_file File.join('~/', 'testing-secrets.yaml')
end

### Platform specific setup
if ENV['PLATFORM_NAME'] == 'browser'

  # Browser environment setup
  browser_world = ENV['BROWSER_TYPE']

  case ENV['BROWSER_TYPE']
  when 'chrome'
    puts 'USING CHROME BROWSER'
    browser_world = ChromeWorld
  when 'firefox'
    puts 'USING FIREFOX BROWSER'
    browser_world = FirefoxWorld
  when 'safari'
    puts 'USING SAFARI BROWSER'
    browser_world = SafariWorld
  else
    puts 'Browser not defined, using the default...'
    browser_world = ChromeWorld
  end

  World { browser_world.new }

else
  # Mobile environment setup

  mobile_world = ENV['PLATFORM_NAME'] == 'ios' ? IosWorld : AndroidWorld
  World { mobile_world.new }
end

# Add methods from modules to World
World Helper
World OsLevelCommand
World StepDefenitionVariables
World CommonComponents
World Account
World JSCheats
