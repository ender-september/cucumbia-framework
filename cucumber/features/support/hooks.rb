# Hooks

fail_shot_taken = nil
scenario_fails_number = nil

Before do
  fail_shot_taken = false
  scenario_fails_number = 0 if scenario_fails_number.nil?
  $logger.info("\n ==================== NEXT SCENARIO ====================")
  $logger.info('Started: General Before block...')

  if MyEnv.browser?
    $browser = Selenium::WebDriver.for(:remote, url: MyEnv.selenium_server_url, desired_capabilities: caps)
    $browser.switch_to.window($browser.window_handles.last)
    $browser.manage.delete_all_cookies
    $browser.manage.window.maximize
  end

  if MyEnv.android? || MyEnv.ios?
    ios_device_specific_config if !MyEnv.true?('BROWSERSTACK') && (ENV['PLATFORM_NAME'] == 'ios')
    uninstall_app if !ENV['APP_BUILD_URL'].nil? && app_installed?

    Appium::Driver.new(caps, true)
    Appium.promote_appium_methods self.class

    start_driver
  end

  self.flow = Flow.new($driver)
  $logger.info('Finished: General Before block...')
end

After do |scenario|
  $logger.info('Started: General After block...')
  if scenario.failed?
    scenario_fails_number += 1
    unless $driver.driver.nil?
      fail_shot_taken = take_fail_shot unless fail_shot_taken == true
      try_close_ios_native_popups if MyEnv.ios?
      quit_driver
    end
    Cucumber.wants_to_quit = true if !ENV['FAILSTOP'].nil? && (scenario_fails_number >= ENV['FAILSTOP'].to_i)
  else
    quit_driver
  end
  $logger.info('Finished: General After block...')
end

Around('not @long', 'not @test') do |scenario, block|
  # Scenario stops with a timeout execption if execution takes more than the stated seconds.
  # Timeout exception by default does not trigger scenario.fail and does not execute the After hook
  Timeout.timeout(600) do
    block.call
  rescue Selenium::WebDriver::Error::TimeoutError => e
    unless $driver.driver.nil?
      fail_shot_taken = take_fail_shot unless fail_shot_taken == true
      quit_driver
    end
    scenario.fail(e)
  end
end

AfterStep do
  after_step_screenshot if ENV['AFTER_STEP_SCREENSHOT']
end
