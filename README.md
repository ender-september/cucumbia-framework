# About  
This is a framework/project template for E2E automated testing based on Ruby and Cucumber. The drivers are Selenium for web and Appium for mobile automation. Those tools can easily (sort of) be replaced with other tools without changing the overall written logic of tests.  

The idea is to have an all-in-one, jump-start, out-of-the-box setup to start writing tests for automation irregardles of tools and environments.

Some of the features:  
* Template of a scenario
* Structured sintax guide - (see vocabulary.md)
* User account data structure
* JavaScript calls for web-based apps
* Commands on the OS level
* Google Cloud API integration
* BrowserStack integration
* Get Mailtrap e-mails
* Easily configurable setup with profiles
* Screenshots for every step or on point of failure (saved in `screenshots` directory)  
* HTML and JSON reports with screenshots
* Script to trigger a test run e.g. with Jenkins CI
* API testing (coming soon)
  
# Browser setup
### Download Selenium server and chromedriver
`brew install selenium-server-standalone`  
`brew tap homebrew/cask && brew cask install chromedriver`  
`brew install geckodriver`  

### Start Selenium server
`selenium-server`

# Mobile setup
### Install Appium
Create a directory for appium and navigate to it  
`npm install appium`  

### For Android
For specific version of `chromedriver`, put the file in the appium root directory. Reach out if you need a compiled fix version of chromedriver for apps that use Crosswalk.  

### For iOS
1. `brew install libimobiledevice --HEAD`  
2. `brew install ideviceinstaller`  
3. `brew install carthage`  
4. `brew install ios-webkit-debug-proxy`
4. `npm install -g ios-deploy`  
5. Configure the WebDriverAgent:  
- Open appium_root_directory/node_modules/appium/node_modules/appium-webdriveragent/WebDriverAgent.xcodeproj  
- Check "Automatically manage signing" and select the Team.  
- In Build Settings tab for WebDriverAgentRunner, find Product Bundle Identifier and instead of `com.facebook.WebDriverAgentRunner` put `com.appium.wda.runner`. Do the same for WebDriverAgentLib: instad of `com.facebook.WebDriverAgentLib` put `com.appium.wda.lib`
Steps in detail: https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md#basic-manual-configuration  
- Click the play button to build the project. If there is an error mentioning RoutingHTTPServer, run `bash ./Scripts/bootstrap.sh -d` from the directory of WebDriverAgent.xcodeproj. Ignore other errors as they should disapear after a test run.  
- Inside the `appium-webdriveragent` directory run `mkdir -p Resources/WebDriverAgent.bundle`  
  
If you get an error code 65, it means either the above setup is not correct or try to go on the device: Settings>General>Device Management where you will see the webdriver app which you have you mark as trusted. If the app is removed after the failed test, kill the Appium server before the cleanup!
  
### Start an Appium server instance
`./node_modules/.bin/appium`  
  
  Useful flags for parallel execution:  
  --port -> set different ports for multiple Appium server instances e.g. one for Android and one for iOS. Default port is 4723.  
  --bootstrap-port -> set different ports that use on device to connect to Appium (Android-only).  
  --session-override -> in case another driver is used in the same session.  
  
# Browser setup
### Download Selenium server and chromedriver
`brew install selenium-server-standalone`  
`brew tap homebrew/cask && brew cask install chromedriver`  
`brew install geckodriver`  

### Start Selenium server
`selenium-server`

# Running tests
  
Navigate to `cucumber` directory  
  
Test execution examples:  

* default - run scenarios with @test tag on browser:  
`bundle exec cucumber`  
* run all scenarios on browser:  
`bundle exec cucumber -p browser` 
* run all scenarios on android:  
`bundle exec cucumber -p android` 
* run the scenario "Login and logout" on iOS with an HTML report generated in the project root:  
`bundle exec cucumber -p ios -p html_report --name "Login and logout"`   
* you can add any additional argument to a profile such as:  
`bundle exec cucumber -p ios --tags @some-tag FAILSTOP=3`   

**Tags:**  
@browser - browser specific tests.  
@test - used to quick run or debug a scenario during development.  
@long - scenarios not limited to a 10 minute execution time.  
@smoke - scenarios covering only the critical functionalities. Executed before detailed functional or regression tests are executed.  
@login-feature, @x-feature, etc. - feature tags 
@unstable - scenarios that sometimes fail due to an uncontrolled factor

### Options  
Stop executing the feature file if the scenario failures amount to a defined number (useful for CI and fast feedback):  
`FAILSTOP=<number>`  
  
Take screenshot after every step:  
`AFTER_STEP_SCREENSHOT=true`  
  
Check out cucumber/config/cucumber.yml for other options!
  
### See also
https://docs.cucumber.io/cucumber/api/

# Creating a scenario
### Structure of a feature file
* **Feature** − Name of the feature under test.  
* **Description** (optional) − Describe the feature under test.
* **Background** (optional) - Steps to run before each scenario in the feature file. Most commonly used to log in a specific user.
* **Scenario** − Name of the test scenario.
* **Given** − Prerequisite before the test steps get executed.
* **When** − Specific condition which should match in order to execute the next step.
* **Then** − What should happen if the condition mentioned in WHEN is satisfied.
* **And** - Additional steps that can be used with any other keywords like **Given**, **When** and **Then**. 

### Checkout vocabulary.md for vocabulary and conventions when forming expressions for scenario steps
