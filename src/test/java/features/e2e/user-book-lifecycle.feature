@e2e
Feature: End-to-end user and book lifecycle

  A single data-chained workflow that mirrors how a real client uses the API:
  provision a user, prove authorization, browse the catalog, build and mutate a
  collection, then tear everything down and confirm the user is gone. Every value
  consumed downstream is produced upstream.

  Background:
    * url baseUrl

  Scenario: Complete user book lifecycle
    * def auth = call read('classpath:features/common/auth.feature')
    * def userId = auth.userId
    * def username = auth.username
    * def credentials = auth.credentials
    * def authHeader = auth.authHeader
    * configure headers = { Authorization: '#(authHeader)' }

    Given path 'Account', 'v1', 'Authorized'
    And request credentials
    When method post
    Then status 200
    And match response == 'true'

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.username == username
    And match response.books == []

    Given path 'BookStore', 'v1', 'Books'
    When method get
    Then status 200
    And assert response.books.length >= 2
    * def selectedIsbn = response.books[0].isbn
    * def replacementIsbn = response.books[1].isbn

    * def collectionOfIsbns = [{ isbn: '#(selectedIsbn)' }]
    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 201
    And match response.books[*].isbn contains selectedIsbn

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.books[*].isbn contains selectedIsbn

    Given path 'BookStore', 'v1', 'Books', selectedIsbn
    And request read('classpath:payloads/replace-isbn.json')
    When method put
    Then status 200
    And match response.books[*].isbn contains replacementIsbn

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.books[*].isbn contains replacementIsbn
    And match response.books[*].isbn !contains selectedIsbn

    * def isbnToDelete = replacementIsbn
    Given path 'BookStore', 'v1', 'Book'
    And request { isbn: '#(isbnToDelete)', userId: '#(userId)' }
    When method delete
    Then status 204

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.books == []

    Given path 'Account', 'v1', 'User', userId
    When method delete
    Then status 204

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 401
