welcome_page = nil
user_email = nil

Then(/^I see the welcome page$/) do
  welcome_page = WelcomePage.new($driver)
end

When('I click on the enter as a guest button') do
  lobby_page = welcome_page.click_signin_as_guest_button
end

Then(/^I click on the login button$/) do
  lobby_page = welcome_page.click_login_button
 end
