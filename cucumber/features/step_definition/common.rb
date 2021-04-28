Given(/^The app is installed$/) do
  OsLevelCommand.install_the_app
end

When(/^I (?:launch|start) the app$/) do
  OsLevelCommand.launch_app
end

Given(/^I restart the app$/) do
  OsLevelCommand.restart_app
end

Given(/^I wait for (\d+) seconds$/) do |seconds|
  sleep(seconds.to_i)
end

Given(/^I log in as a (.*?)$/) do |user_type|
  self.lobby_page = flow.log_in(user_type)
  self.expected_wallet = lobby_page.wallet_amount
end

Then('I see the lobby page') do
  expect(current_page?(LobbyPage.unique_element)).to be true
end

And('I logout') do
  logout_with_local_storage_data
end

And('I reload the page') do
  reload_window
end
