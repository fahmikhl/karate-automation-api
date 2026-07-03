@negative
Feature: Authentication and validation failures

  Confirms the API rejects bad credentials, missing or invalid tokens, duplicate
  registrations and malformed payloads with the correct status and message.

  Background:
    * url baseUrl
    * def fakeUserId = java.util.UUID.randomUUID() + ''

  Scenario: Token generation reports failure for invalid credentials
    Given path 'Account', 'v1', 'GenerateToken'
    And request { userName: 'ghost_user_qa', password: 'WrongPass#1' }
    When method post
    Then status 200
    And match response.status == 'Failed'
    And match response.result == 'User authorization failed.'
    And match response.token == null

  Scenario: Authorization check fails for an unknown user
    Given path 'Account', 'v1', 'Authorized'
    And request { userName: 'ghost_user_qa', password: 'WrongPass#1' }
    When method post
    Then status 404
    And match response.message == 'User not found!'

  Scenario: Registering an existing username is rejected
    Given path 'Account', 'v1', 'User'
    And request fixtureUser
    When method post
    Then status 406
    And match response.message == 'User exists!'

  Scenario: Registration without a password is rejected
    Given path 'Account', 'v1', 'User'
    And request { userName: 'incomplete_user_qa' }
    When method post
    Then status 400

  Scenario: Retrieving a user without a token is unauthorized
    Given path 'Account', 'v1', 'User', fakeUserId
    When method get
    Then status 401

  Scenario: Retrieving a user with an invalid token is unauthorized
    Given path 'Account', 'v1', 'User', fakeUserId
    And header Authorization = 'Bearer invalid.jwt.token'
    When method get
    Then status 401

  Scenario: Adding a book without a token is unauthorized
    Given path 'BookStore', 'v1', 'Books'
    And request { userId: '#(fakeUserId)', collectionOfIsbns: [{ isbn: '9781449325862' }] }
    When method post
    Then status 401
