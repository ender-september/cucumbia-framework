# Running with Jenkins

### Command to trigger a run

In a Jenkins project use the command: 
`run-script.sh "env variables" "cucumber profile and flags"`

### Test reports in plain

When the test results are in plain text, go to Manage Jenkins->Script Console and paste the following `System.setProperty("hudson.model.DirectoryBrowserSupport.CSP", "sandbox allow-scripts allow-popups allow-popups-to-escape-sandbox; style-src 'unsafe-inline' *;")`, than click on Run.