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
require 'dotenv'
require File.join(__dir__, '../step_definition/step_definition_variables.rb')
Dir[File.join(__dir__, 'core', '**/*.rb')].sort.each { |file| require file }

# Environment and configuration variables
class MyEnv
  TRUTHY_VALUES = %w[t true yes y 1].freeze
  FALSEY_VALUES = %w[f false n no 0].freeze

  def self.true?(value)
    return false if ENV[value].nil?
    return false if FALSEY_VALUES.include?(ENV[value].to_s.downcase)
    return true if TRUTHY_VALUES.include?(ENV[value].to_s.downcase)

    raise "Invalid value '#{value}' for boolean casting!"
  end

  def self.project_id
    ENV['PROJECT_ID']
  end

  def self.browser?
    ENV['PLATFORM_NAME'] == 'browser'
  end

  def self.android?
    ENV['PLATFORM_NAME'] == 'android'
  end

  def self.ios?
    ENV['PLATFORM_NAME'] == 'ios'
  end

  def self.appium_config_file
    File.join(__dir__, "appium_#{ENV['PLATFORM_NAME']}_caps.txt")
  end

  def self.append_appium_config_file(conf, value)
    conf = "#{conf}="
    # Do not append if the config already exists
    return if File.foreach(MyEnv.appium_config_file).grep(/#{conf}/).any?

    File.open(MyEnv.appium_config_file, 'a') do |f|
      f.write "\n#{conf}\"#{value}\""
    end
  end

  def self.selenium_server_url
    ENV['SELENIUM_SERVER_URL'] || 'http://127.0.0.1:4444/wd/hub'
  end

  def self.appium_server_url
    ENV['APPIUM_SERVER_URL'] || 'http://127.0.0.1:4723/wd/hub'
    "https://#{ENV['BS_USER']}:#{ENV['BS_KEY']}@hub-cloud.browserstack.com/wd/hub" if MyEnv.true?('BROWSERSTACK')
  end

  def self.app_build_path
    uri_path = ENV['APP_BUILD_URL']

    # if uri is a web URL
    return uri_path if uri_path.include?('://')

    dir_path = File.join(Dir.pwd, uri_path) if uri_path == 'resources'
    dir_path = File.join(ENV['HOME'], uri_path) unless uri_path == 'resources'

    extension = ENV['PLATFORM_NAME'] == 'ios' ? 'ipa' : 'apk'
    extension = 'app' if MyEnv.true?('IOS_SIMULATOR')

    Dir["#{dir_path}/*.#{extension}"].first
  end

  def self.browserstack_caps(caps_hash)
    caps_hash[:caps]['browserstack.key'] = ENV['BS_KEY']
    caps_hash[:caps]['device'] = ENV['BS_DEVICE']
    caps_hash[:caps]['deviceName'] = ENV['BS_DEVICE']
    caps_hash[:caps]['os_version'] = ENV['BS_OS_VERSION']
    caps_hash[:caps]['project'] = ENV['BS_PROJECT']
    caps_hash[:caps]['build'] = ENV['BS_BUILD']
    caps_hash[:caps]['name'] = ENV['BS_NAME']
    caps_hash[:caps]['browserstack.user'] = ENV['BS_USER']
    caps_hash
  end
end

# Android specific configurations
class AndroidWorld
  extend OsLevelCommand

  def caps
    puts 'Running on Android...'
    caps_hash = Appium.load_appium_txt file: MyEnv.appium_config_file

    caps_hash[:appium_lib][:server_url] = MyEnv.appium_server_url
    caps_hash[:caps][:appPackage] = ENV['APP_PACKAGE_NAME']
    caps_hash[:caps][:appActivity] = ENV['APP_ACTIVITY']

    caps_hash[:caps][:app] = MyEnv.app_build_path unless ENV['APP_BUILD_URL'].nil?
    caps_hash[:caps][:fullReset] = ENV['FULL_RESET'] unless ENV['FULL_RESET'].nil?
    caps_hash[:caps][:unlockType] = ENV['UNLOCK_TYPE'] unless ENV['UNLOCK_TYPE'].nil?
    caps_hash[:caps][:unlockKey] = ENV['UNLOCK_KEY'] unless ENV['UNLOCK_KEY'].nil?

    caps_hash = MyEnv.browserstack_caps(caps_hash) if MyEnv.true?('BROWSERSTACK')

    caps_hash
  end
end

# iOS specific configurations
class IosWorld
  extend OsLevelCommand

  def caps
    puts 'Running on iOS...'
    caps_hash = Appium.load_appium_txt file: MyEnv.appium_config_file

    caps_hash[:appium_lib][:server_url] = MyEnv.appium_server_url
    caps_hash[:caps][:bundleId] = ENV['APP_PACKAGE_NAME']

    caps_hash[:caps][:app] = MyEnv.app_build_path unless ENV['APP_BUILD_URL'].nil?
    caps_hash[:caps][:fullReset] = ENV['FULL_RESET'] unless ENV['FULL_RESET'].nil?

    unless MyEnv.true?('BROWSERSTACK')
      caps_hash[:caps][:startIWDP] = 'true'
      caps_hash[:caps][:updatedWDABundleId] = 'com.appium.wda.runner'
    end
    binding.pry
    caps_hash = MyEnv.browserstack_caps(caps_hash) if MyEnv.true?('BROWSERSTACK')

    caps_hash
  end

  def ios_device_specific_config
    if MyEnv.true?('IOS_SIMULATOR')
      device_name = 'iPhone Simulator'
      platform_version = ENV['PLATFORM_VERSION'] || '14.3'
    else
      device_name = `ideviceinfo | grep -i DeviceName`.sub! 'DeviceName: ', ''

      raise 'iOS device not found. Check connection... Tip: You can use the command: ideviceinfo' if device_name.nil?

      device_name = device_name.strip
      platform_version = `ideviceinfo | grep -i ProductVersion`.sub! 'ProductVersion: ', ''
      platform_version = /^\d+\.[1-9]\d*/.match(platform_version)
    end

    $logger.info("Device name: #{device_name}")
    $logger.info("Platform version: #{platform_version}")

    MyEnv.append_appium_config_file('deviceName', device_name)
    MyEnv.append_appium_config_file('platformVersion', platform_version)
  end
end

# Chrome specific configurations
class ChromeWorld
  def caps
    capabilities_config = {
      platform: :MAC
    }

    capabilities_config[:chromeOptions] = { 'args' => ['headless'] } if MyEnv.true?('HEADLESS_BROWSER')

    Selenium::WebDriver::Remote::Capabilities.send(:chrome, capabilities_config)
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
end

# Safari specific configurations
class SafariWorld
  def caps
    capabilities_config = {
      platform: :MAC
    }
    Selenium::WebDriver::Remote::Capabilities.send(:safari, capabilities_config)
  end
end

################
### Script start
################

# Load environment variables from cucumber/.env
Dotenv.load

# Initialize the logger and create log file
$logger = LoggerBuilder.new('logfile.log')

# Create directory for screenshots
Dir.mkdir('screenshots') unless Dir.exist?('screenshots')

### App specific setup
element_path_file = File.join(__dir__, "/core/element_path_#{ENV['PLATFORM_NAME']}.yaml")
$element_path = ElementRegistry.new(element_path_file).element_path_file_hashmap

# Load property files
$users = YAML.load_file File.join(__dir__, '/core/users.yaml')

# Mobile environment setup
mobile_world = ENV['PLATFORM_NAME'] == 'ios' ? IosWorld : AndroidWorld
World { mobile_world.new }

unless ENV['BROWSER_TYPE'].nil?
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
end

# Add methods from modules to World
World Helper
World OsLevelCommand
World StepDefenitionVariables
World Account
World MobileHandler
World Screenshoter
World Waiter
