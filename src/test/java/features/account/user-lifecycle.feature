@regression
Feature: Account user lifecycle

  Exercises the account resource end to end for a freshly provisioned user:
  identity retrieval, authorization check, and deletion. Each scenario provisions
  its own user and removes it afterwards so scenarios stay independent.

  Background:
    * def auth = call read('classpath:features/common/auth.feature')
    * def userId = auth.userId
    * def username = auth.username
    * def credentials = auth.credentials
    * def authHeader = auth.authHeader
    * url baseUrl
    * configure headers = { Authorization: '#(authHeader)' }
    * configure afterScenario = function(){ karate.call('classpath:features/common/cleanup.feature@deleteUser', { userId: userId, authHeader: authHeader }) }

  Scenario: A newly created user has the expected identity and an empty collection
    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.userId == userId
    And match response.username == username
    And match response.books == []

  Scenario: Valid credentials are reported as authorized
    Given path 'Account', 'v1', 'Authorized'
    And request credentials
    When method post
    Then status 200
    And match response == 'true'

  Scenario: A deleted user can no longer be retrieved
    Given path 'Account', 'v1', 'User', userId
    When method delete
    Then status 204

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 401
