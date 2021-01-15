# Hooks

start_mobile_setup = nil
fail_shot_taken = nil
scenario_fails_number = nil

Before do
  fail_shot_taken = false
  scenario_fails_number = 0 if scenario_fails_number.nil?
  $logger.info("\n ==================== NEXT SCENARIO ====================")
  $logger.info('Started: General Before block...')

  if browser?
    $driver = Selenium::WebDriver.for(:remote, url: server_url, desired_capabilities: caps)
    $driver.switch_to.window($driver.window_handles.last)
    $driver.manage.delete_all_cookies

    # ChromeDriver has bug with maximizing
    unless ENV['BROWSER_TYPE'].nil? || ENV['BROWSER_TYPE'] == 'chrome'
      $driver.manage.window.maximize
    end
    try_times(2, method(:open_url), ENV["BROWSER_URL"])
  
  else
    # Mobile setup
    start_mobile_setup = true if start_mobile_setup.nil?
    if start_mobile_setup == true      
      app_bundle
      ios_device_specific_config if ENV['PLATFORM_NAME'] == 'ios'
      install_app unless ENV['APP_BUILD_URL'].nil?
      unlock_device('pin', ENV['PIN']) unless ENV['PIN'].nil?
      start_mobile_setup = false unless MyEnv.true?('FULL_RESET')
      
      Appium::Driver.new caps
      Appium.promote_appium_methods self.class
    end

    $driver.start_driver

    # If iOS spams with updates and other notification, try to close the popups
    if ios?
      close_popup_buttons = ['Cancel', 'Close', 'Later', 'Don\'t Allow', 'Remind Me Later']

      close_popup_buttons.each do |x|
        begin
          $driver.find_element(:id, x).click
        rescue StandardError
        ensure
          next
        end
      end
    end
    enter_webview
  end

  self.flow = Flow.new($driver)
  $logger.info('Finished: General Before block...')
end

After do |scenario|
  $logger.info('Started: General After block...')
  if scenario.failed?
    scenario_fails_number += 1
    unless $driver.nil?
      fail_shot_taken = take_fail_shot unless fail_shot_taken == true
      try_close_ios_native_popups if ios?
      quit_driver
    end
    unless ENV['FAILSTOP'].nil?
      if scenario_fails_number >= ENV['FAILSTOP'].to_i
        Cucumber.wants_to_quit = true
      end
    end
  else
    quit_driver
  end
  $logger.info('Finished: General After block...')
end

Around('not @long', 'not @test') do |scenario, block|
  # Scenario stops with timeout execption if execution takes more than stated seconds.
  # Timeout exception by default does not trigger scenario.fail and does not finish with executing the After hook
  begin
    if ios?
      block.call
    else
      Timeout.timeout(600) do
        block.call
      end
    end
  rescue Selenium::WebDriver::Error::TimeoutError => e
    unless $driver.nil?
      fail_shot_taken = take_fail_shot unless fail_shot_taken == true
      quit_driver
    end
    scenario.fail(e)
  end
end

AfterStep do
  after_step_screenshot if ENV['AFTER_STEP_SCREENSHOT']
end

Before('not @test', '@backoffice') do
  $logger.info 'Started: Before backoffice setup...'

  try_times(2, method(:open_url), ENV['BACKOFFICE_URL'])
    
  self.backoffice_flow = BackofficePages.new($driver)
  backoffice_pages.log_in

  # Do something in the backoffice

  $logger.info 'Finished: Before backoffice setup...'
  open_url(ENV['BROWSER_URL']) if browser?
end

do_something = false
Before('not @test', 'not @login-feature') do
  flow_successful = nil
  do_something = true if flow_successful == true
end