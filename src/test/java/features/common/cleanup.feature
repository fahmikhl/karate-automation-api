@ignore
Feature: Reusable cleanup actions

  Removes test data created during a scenario. Callers pass userId and authHeader;
  deletions are idempotent from the test's perspective so cleanup never fails a run.

  Background:
    * url baseUrl
    * configure headers = { Authorization: '#(authHeader)' }

  @emptyCollection
  Scenario: emptyCollection
    Given path 'BookStore', 'v1', 'Books'
    And param UserId = userId
    When method delete
    Then assert responseStatus == 204 || responseStatus == 401

  @deleteUser
  Scenario: deleteUser
    Given path 'Account', 'v1', 'User', userId
    When method delete
    Then assert responseStatus == 204 || responseStatus == 200 || responseStatus == 401
