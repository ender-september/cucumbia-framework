@login-feature @test
Feature: Login Feature
  Scenario: Log in as a guest for the first time
    Given I see the welcome page
    When I click on the enter as a guest button
    Then I see the lobby page
