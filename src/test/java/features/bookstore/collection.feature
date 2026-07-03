@regression
Feature: User book collection management

  Manages the books owned by a user: add, replace, delete one, delete all.
  Every scenario provisions its own user, selects real ISBNs from the live
  catalog, and deletes the user afterwards. Nothing is hardcoded.

  Background:
    * def auth = call read('classpath:features/common/auth.feature')
    * def userId = auth.userId
    * def authHeader = auth.authHeader
    * url baseUrl
    * configure headers = { Authorization: '#(authHeader)' }
    * configure afterScenario = function(){ karate.call('classpath:features/common/cleanup.feature@deleteUser', { userId: userId, authHeader: authHeader }) }

    Given path 'BookStore', 'v1', 'Books'
    When method get
    Then status 200
    * def catalog = response.books
    * def selectedIsbn = catalog[0].isbn
    * def replacementIsbn = catalog[1].isbn

  Scenario: A book added to the collection is owned by the user
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

  Scenario: A book in the collection can be replaced with another
    * def collectionOfIsbns = [{ isbn: '#(selectedIsbn)' }]
    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 201

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

  Scenario: A single book can be removed from the collection
    * def collectionOfIsbns = [{ isbn: '#(selectedIsbn)' }]
    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 201

    * def isbnToDelete = selectedIsbn
    Given path 'BookStore', 'v1', 'Book'
    And request read('classpath:payloads/delete-book.json')
    When method delete
    Then status 204

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.books == []

  Scenario: The entire collection can be cleared for a user
    * def collectionOfIsbns = [{ isbn: '#(selectedIsbn)' }, { isbn: '#(replacementIsbn)' }]
    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 201

    Given path 'BookStore', 'v1', 'Books'
    And param UserId = userId
    When method delete
    Then status 204

    Given path 'Account', 'v1', 'User', userId
    When method get
    Then status 200
    And match response.books == []

  @negative
  Scenario: Adding a book already in the collection is rejected
    * def collectionOfIsbns = [{ isbn: '#(selectedIsbn)' }]
    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 201

    Given path 'BookStore', 'v1', 'Books'
    And request read('classpath:payloads/add-books.json')
    When method post
    Then status 400
    And match response.message contains 'ISBN already present'
