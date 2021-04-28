# Methods for screeshots
module Screenshoter
  def take_screenshot(filename)
    return if $driver.driver.nil?

    file_path = File.join(Dir.pwd, "screenshots/#{filename}.png")
    if MyEnv.browser?
      $browser.save_screenshot(file_path)
    else
      screenshot(file_path)
    end
    file_path
  end

  def embed_screenshot_in_report(file_path)
    encoded_img = Base64.encode64(File.open(file_path).read)
    embed("data:image/png;base64,#{encoded_img}", 'image/png')
  end

  def take_fail_shot
    failshot_file_name = "#{ENV['PLATFORM_NAME']}-failshot-#{timestamp}"
    failshot_path = take_screenshot(failshot_file_name)
    embed_screenshot_in_report(failshot_path)
    puts "Screenshot when test failed taken with the filename: #{failshot_file_name}.png"
    true
  end

  def after_step_screenshot
    shot_file_name = "#{ENV['PLATFORM_NAME']}-afterstep-#{timestamp}"
    shot_path = take_screenshot(shot_file_name)
    embed_screenshot_in_report(shot_path)
  end

  def take_element_screenshot(element, filename)
    $driver.element_screenshot(element, File.join(Dir.pwd, "screenshots/#{filename}.png"))
  end
end
