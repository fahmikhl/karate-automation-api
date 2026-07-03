@ignore
Feature: Reusable authentication

  Registers a fresh user and generates a JWT. Intended to be invoked through
  karate.callSingle so the same user and token are reused across the run.

  Background:
    * url baseUrl

  Scenario: Provision an authenticated user
    * def suffix = java.util.UUID.randomUUID().toString().replaceAll('-', '').substring(0, 10)
    * def username = 'qa_' + suffix
    * def password = 'QaPass#' + (1000 + Math.floor(Math.random() * 9000))
    * def credentials = { userName: '#(username)', password: '#(password)' }

    Given path 'Account', 'v1', 'User'
    And request read('classpath:payloads/register-user.json')
    When method post
    Then status 201
    And match response.userID == '#uuid'
    And match response.username == username
    * def userId = response.userID

    Given path 'Account', 'v1', 'GenerateToken'
    And request credentials
    When method post
    Then status 200
    And match response.status == 'Success'
    And match response.result == 'User authorized successfully.'
    And match response.token == '#present'
    * def accessToken = response.token
    * def authHeader = 'Bearer ' + accessToken
