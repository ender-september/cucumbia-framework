# About  
This is a framework/project template for E2E automated testing based on programming language Ruby and gherkin framework Cucumber. By default, the drivers are Selenium for web and Appium for mobile automation. The CI for triggering test runs is Jenkins. Those tools can be easily (sort of) be replaced with other tools without changing the overall written logic of tests.  
  
The idea is to have an all-in-one, jump-start, out-of-the-box setup to start writing tests for automation irregardles of tools and environments. Currently, the framework supports Selenium for web and Appium for mobile.  

Some of the features:  
* Template of a scenario
* User account data structure
* JavaScript calls for web-based apps
* Commands on the OS level
* Get Google Sheet data
* Get Mailtrap e-mails
* Easily configurable setup with profiles
* Screenshots for every step or on point of failure (saved in `screenshots` directory)  
* HTML and JSON reports with screenshots
* Jenkins CI setup
* API testing (coming soon)

# Code setup  
Search and rename the text instances of:  
`app_abrv` - abriviation of the AUT - all lower case  
`app_name` - full name of the application - all lower case  
`app_package_name` - name of the app package  
  
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
5. Optional: `gem install xcpretty`
6. Configure the WebDriverAgent:  
Open appium_root_directory/node_modules/appium-webdriveragent/WebDriverAgent.xcodeproj
Check "Automatically manage signing" and select the Team.
In Build Settings tab find Product Bundle Identifier and instead of `com.facebook.WebDriverAgent(...)` put `io.appium.WebDriverAgent(...)`. Do these both for WebDriverAgentLib and WebDriverAgentRunner.  
Steps in detail: https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md#basic-manual-configuration  
Click the play button to build the project. If there is an error mentioning RoutingHTTPServer, run `bash ./Scripts/bootstrap.sh -d` from the directory of WebDriverAgent.xcodeproj. Ignore other errors as they should disapear after a test run.

### Start an Appium server instance for Android
``./node_modules/.bin/appium --port 4724 --bootstrap-port 63324 --session-override --chromedriver-executable=`pwd`/chromedriver``  

### Start an Appium server instance for iOS
`./node_modules/.bin/appium --session-override`  

# Running tests
  
Navigate to `e2e-automated-testing/cucumber`  
  
Test execution profiles (defined in config/cucumber.yml):  

* default - run scenarios with @test tag on app_name and chrome:  
`bundle exec cucumber`  
* run scenarios without @mobile tag on app_name and browser(chrome if not specified):  
`bundle exec cucumber -p app_abrv-browser`  
* run scenarios without @mobile tag on app_name and android:  
`bundle exec cucumber -p app_abrv-android` 
* you can add any additional argument to a profile such as:  
`bundle exec cucumber -p app_abrv-browser BROWSER=firefox --tags @some-tag FAILSTOP=3`   

**Tags:**  
@test - used to quick run or debug a scenario during development.  
@mobile - mobile specific tests.  
@browser - browser specific tests.  
@long - scenarios not limited to a 10 minute execution time.  
@smoke - check that the critical functionalities are working fine. Executed before detailed functional or regression tests are executed.  
@team-missions, @lobby-views, etc. - feature tags 
@unstable - scenarios that sometimes fail due to an uncontrolled factor

### Options
Specify the browser:  
`BROWSER=[firefox, safari, chrome(default)]`  
  
Stop executing the feature file if the scenario failures amount to a defined number (useful for CI and fast feedback):  
`FAILSTOP=number`  
  
Take screenshot after every step   
`AFTER_STEP_SCREENSHOT=true`  
  
### See also
https://docs.cucumber.io/cucumber/api/

# Creating a scenario
### Structure of a feature file
* **Feature** − Name of the feature under test.  
* **Description** (optional) − Describe the feature under test.
* **Background** (optional) - Steps to run before each scenario in the feature file. Most commonly used to specify a user for logging in after which the Lobby page is displayed.
* **Scenario** − Name of the test scenario.
* **Given** − Prerequisite before the test steps get executed.
* **When** − Specific condition which should match in order to execute the next step.
* **Then** − What should happen if the condition mentioned in WHEN is satisfied.
* **And** - Additional steps that can be used with any other keywords like **Given**, **When** and **Then**. 

### Checkout vocabulary.md for vocabulary and conventions when forming expressions for scenario steps

# Jenkins
When the test result is in plain text, go to Manage Jenkins->Script Console and paste the following `System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "sandbox allow-scripts allow-popups allow-popups-to-escape-sandbox; style-src 'unsafe-inline' *;")`, than click on Run.
