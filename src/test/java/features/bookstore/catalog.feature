@regression
Feature: Book catalog browsing

  The catalog is public and read-only. These scenarios validate the catalog
  contract and that a single book can be retrieved and matches its catalog entry.

  Background:
    * url baseUrl

  @contract
  Scenario: The catalog returns a schema-valid, non-empty list of books
    Given path 'BookStore', 'v1', 'Books'
    When method get
    Then status 200
    And match response == read('classpath:schemas/all-books.json')
    And assert response.books.length > 0

  @contract
  Scenario: A single book is retrievable by ISBN and matches the catalog entry
    Given path 'BookStore', 'v1', 'Books'
    When method get
    Then status 200
    * def catalogBook = response.books[0]
    * def selectedIsbn = catalogBook.isbn

    Given path 'BookStore', 'v1', 'Book'
    And param ISBN = selectedIsbn
    When method get
    Then status 200
    And match response == read('classpath:schemas/book.json')
    And match response.isbn == selectedIsbn
    And match response.title == catalogBook.title
    And match response.author == catalogBook.author

  @negative
  Scenario: Requesting a non-existent ISBN is rejected
    Given path 'BookStore', 'v1', 'Book'
    And param ISBN = 'not-a-real-isbn'
    When method get
    Then status 400
    And match response.message == '#present'
