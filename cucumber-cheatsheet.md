## Features and Step Definitions

### Gherkin Keywords
 - Feature
 - Background
 - Scenario
 - Given
 - When
 - Then
 - And
 - But
 - *
 - Scenario Outline 
 - Examples

### Capturing arguments via groups
```
Given I have deposited $100 in my Account
...

Given /I have deposited \$(\d+) in my Account/ do |amount| 
  # TODO: code goes here
end


Given I have deposited $10 in my Checking Account
...

Given /I have deposited \$(\d+) in my (\w+) Account/ do |amount, account_type| 
  # TODO: code goes here
end
```

### The Question Mark Modifier
```
Given I have 1 cucumber in my basket 
Given I have 256 cucumbers in my basket
...

Given /I have (\d+) cucumbers? in my basket/ do |number| 
  # TODO: code goes here
end
```

### Noncapturing Groups
```
When I visit the homepage
When I go to the homepage
...

When /I (?:visit|go to) the homepage/ do 
  # TODO: code goes here
end
```

### Data Tables
```
Feature:
  Scenario:
    Given a board like this: 
    |   | 1  | 2  | 3  |
    | 1 |    |    |    |
    | 2 |    |    |    |
    | 3 |    |    |    |

    When player x plays in row 2, column 1 Then the board should look like this:
    |   | 1  | 2  | 3  |
    | 1 |    |    |    |
    | 2 | x  |    |    | 
    | 3 |    |    |    |

Given /^a board like this:$/ do |table| 
  @board = table.raw
end

When /^player x plays in row (\d+), column (\d+)$/ do |row, col| 
  row, col = row.to_i, col.to_i
  @board[row][col] = 'x'
end

Then /^the board should look like this:$/ do |expected_table|
  expected_table.diff!(@board)
end
```

### Scenario Outline
```
Scenario Outline: Withdraw fixed amount
Given I have <Balance> in my account
When I choose to withdraw the fixed amount of <Withdrawal> Then I should <Outcome>
And the balance of my account should be <Remaining>

Examples: Successful withdrawal
| Balance | Withdrawal | Outcome           | Remaining |
| $500    | $50        | receive $50 cash  | $450      |
| $500    | $100       | receive $100 cash | $450      |


Examples: Attempt to withdraw too much
| Balance | Withdrawal | Outcome              | Remaining |
| $100    | $200       | see an error message | $100      | 
| $0      | $50        | see an error message | $0        |
```

### Nested Steps
```
Given /^a (\w+) widget with the following details:$/ do |color, details_table|
  step "I create a #{color} widget with the following details:", details_table 
  steps %{
    And I register the #{color} widget
    And I activate the #{color} widget 
  }
end
```

### Doc Strings
```
Scenario: Ban Unscrupulous Users
When I behave unscrupulously
Then I should receive an email containing:
     """
     Dear Sir,
     Your account privileges have been revoked due to your unscrupulous behavior.
     Sincerely,
     The Management 
     """
And my account should be locked
```

### Transforms
```
CAPTURE_CASH_AMOUNT = Transform /^\$(\d+)$/ do |digits| 
  digits.to_i
end

Given /^I have deposited (#{CAPTURE_CASH_AMOUNT}) in my account$/ do |amount| 
  my_account = Account.new
  my_account.deposit(amount)
  my_account.balance.should eq(amount), 
  "Expected the balance to be #{amount} but it was #{my_account.balance}" 
end

Transform /^(£|\$|€)(\d+)$/ do | currency_symbol, digits | 
  Currency::Money.new(digits, currency_symbol)
end
```

### Tags
```
@nightly @slow
Feature: Nightly Reports
@widgets
Scenario: Generate overnight widgets report
...
```

### Pending Steps
```
Given /^I have deposited \$(\d+) in my account$/ do |amount| 
  pending("Need to design the Account interface")
end
```

## Command Line Options

### Formatters
**pretty**    : Prints the feature as is - in colours. Used by default.  
**progress**  : Prints one character per scenario.  
**html**      : Generates HTML report.  
**json**      : Prints the feature as JSON  
**junit**     : Generates a report similar to Ant+JUnit (can be useful for CI).  
**usage**     : Lists all of the step definitions in your project, as well as the steps that are using it. It shows you unused step definitions, and it sorts the step definitions by their average execution time.  
**stepdefs**  : Prints All step definitions with their locations. Same as the usage formatter, except that steps are not printed.  
**rerun**     : Prints failing files with line numbers.

**Examples:**
```
cucumber --format progress
..U--..F..
```

Each character represents the status of each step:

 * . means passing.
 * U means undefined.
 * \- means skipped (or a Scenario Outline step).
 * F means failing.

```
cucumber -f pretty -f html --out cukes.html -f rerun --out rerun.txt
```
This tells Cucumber to write the HTML report to the file cukes.html, then rerun output to rerun.txt, and finally display the pretty formatter’s output in the console. 


### Useful Options
```
--retry 1
```
Reruns a scenario one more time if it failied. 

```
-b, --backtrace
```
Prints a full backtrace for each failure instead of a shortened one. 

```
-v, --verbose
```
Outputs places where Cucumber is looking for code.

```
-r, --require
```
Tells Cucumber explicitly where to load code from.  

```
-w, --wip
```
Fail if there are any passing scenarios.

```
-S, --strict
```
Fail if there are any undefined or pending steps. 

```
-d, --dry-run
```
Invokes formatters without executing the steps.
This also omits the loading of your support/env.rb file if it exists.


### Filtering

#### Filltering with Tag Expressions

```
$ cucumber --tags @focus,@email
```
@focus OR @email

```
$ cucumber --tags @fast --tags @focus,@email
```
@fast AND (@focus OR @email)

```
$ cucumber --tags 'not @slow' --tags @focus,@email
```
NOT @slow AND (@focus OR @email)

```
$ cucumber --tags @javascript:10
```
Execute all scenarios tagged with @javascript, failing if
more than ten are found.

#### Filtering on Lines
```
$ cucumber features/something.feature --line 45
$ cucumber features/something.feature:45
$ cucumber features/something.feature:45:89:107
```

#### Filtering on Names
```
$ cucumber --name logout
```
Runs scenarios that have logout in their name.

```
$ cucumber --exclude logout
```
Runs all scenarios except those with logout in their name.

### Hooks
#### Scenario hooks
Before, After, Around.  

#### Step hooks
AfterStep.  

#### Global hooks
AfterConfiguration.  

#### Tagged hooks
```
Before('@cucumis, @sativus', 'not @aqua') do
  # This will only run before scenarios tagged
  # with (@cucumis OR @sativus) AND NOT @aqua
end
```