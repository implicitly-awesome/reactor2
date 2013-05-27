Feature: Transaction API

  Scenario: I can get the list of Transactions
    Given I have the list of entities:
      |    Model     |                       Attrs                      |
      | Transaction  | {"guid":"1111", "user_guid":"777", "action":"c"} |
      | Transaction  | {"guid":"2222", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"3333", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"4444", "user_guid":"777", "action":"d"} |
    And I send a GET request to "/api/v1/transactions/" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "4"



  Scenario: I can get exact Transaction
    Given I have the list of entities:
      |    Model     |                       Attrs                      |
      | Transaction  | {"guid":"1111", "user_guid":"777", "action":"c"} |
      | Transaction  | {"guid":"2222", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"3333", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"4444", "user_guid":"777", "action":"d"} |
    And I send a GET request to "/api/v1/transactions/3333" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "1"
    And the JSON response should have text: "u"
    And the JSON response should have text: "3333"



  Scenario: I can't create a Transaction without a user_guid
    Given I have the list of entities:
      |    Model     |                       Attrs                      |
      | Transaction  | {"guid":"1111", "user_guid":"777", "action":"c"} |
      | Transaction  | {"guid":"2222", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"3333", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"4444", "user_guid":"777", "action":"d"} |
    And I send a POST request to "/api/v1/transactions/" with the following:
      |  user_guid  |                ""                 |
      | transaction |   {"guid":"5555", "action":"d"}   |
    Then the response status should be "400"
    And the quantity of Transaction is "4"



  Scenario: I can't create a Transaction without an action
    Given I have the list of entities:
      |    Model     |                       Attrs                      |
      | Transaction  | {"guid":"1111", "user_guid":"777", "action":"c"} |
      | Transaction  | {"guid":"2222", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"3333", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"4444", "user_guid":"777", "action":"d"} |
    And I send a POST request to "/api/v1/transactions/" with the following:
      |  user_guid  |        "777"        |
      | transaction |   {"guid":"5555"}   |
    Then the response status should be "400"
    And the quantity of Transaction is "4"



  Scenario: I can't create a Transaction without a guid
    Given I have the list of entities:
      |    Model     |                       Attrs                      |
      | Transaction  | {"guid":"1111", "user_guid":"777", "action":"c"} |
      | Transaction  | {"guid":"2222", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"3333", "user_guid":"777", "action":"u"} |
      | Transaction  | {"guid":"4444", "user_guid":"777", "action":"d"} |
    And I send a POST request to "/api/v1/transactions/" with the following:
      |  user_guid  |      "777"      |
      | transaction |   {"guid":""}   |
    Then the response status should be "400"
    And the quantity of Transaction is "4"



  Scenario: I can update a Transaction
    Given the Transaction with the following:
      | Guid | User_guid | Action |
      | 1111 |    777    |    c   |
    When I send a PUT request to "/api/v1/transactions/1111" with the following:
      | transaction |   {"action":"u"}   |
    Then the response status should be "200"
    And the Transaction should have "action" field with value "u"



  Scenario: I can't update a Transaction without a user_guid
    Given the Transaction with the following:
      | Guid | User_guid | Action |
      | 1111 |    777    |    c   |
    When I send a PUT request to "/api/v1/transactions/1111" with the following:
      | transaction |   {"action":"u", "user_guid":""}   |
    Then the response status should be "400"



  Scenario: I can't update a Transaction without an action
    Given the Transaction with the following:
      | Guid | User_guid | Action |
      | 1111 |    777    |    c   |
    When I send a PUT request to "/api/v1/transactions/1111" with the following:
      | transaction |   {"action":"", "user_guid":"777"}   |
    Then the response status should be "400"