Feature: Transaction pack API

  Scenario: I can get the list of Transaction packs
    Given I have the list of entities:
      |      Model       |               Attrs              |
      | TransactionPack  | {"user_guid":"111","guid":"111"} |
      | TransactionPack  | {"user_guid":"222","guid":"222"} |
      | TransactionPack  | {"user_guid":"333","guid":"333"} |
      | TransactionPack  | {"user_guid":"444","guid":"444"} |
    And I send a GET request to "/api/v1/transaction_packs/" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "4"



  Scenario: I can get exact Transaction pack
    Given I have the list of entities:
      |      Model       |               Attrs              |
      | TransactionPack  | {"user_guid":"111","guid":"111"} |
      | TransactionPack  | {"user_guid":"222","guid":"222"} |
      | TransactionPack  | {"user_guid":"333","guid":"333"} |
      | TransactionPack  | {"user_guid":"444","guid":"444"} |
    And I send a GET request to "/api/v1/transaction_packs/222" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "1"
    And the JSON response should have text: "222"



  Scenario: I can't create a Transaction pack without a user
    Given I have the list of entities:
      |      Model       |               Attrs              |
      | TransactionPack  | {"user_guid":"111","guid":"111"} |
      | TransactionPack  | {"user_guid":"222","guid":"222"} |
      | TransactionPack  | {"user_guid":"333","guid":"333"} |
      | TransactionPack  | {"user_guid":"444","guid":"444"} |
    And the User with the following:
      | Guid | Name |
      | 1111 | test |
    And I send a POST request to "/api/v1/transaction_packs/" with the following:
      | transaction_pack |   {"sync_pack":[{"action":"c","row_guid":"1111"},{"action":"u","row_guid":"2222"},{"action":"d","row_guid":"3333"}]}   |
      | user_guid        |      |
    Then the response status should be "400"
    And the quantity of TransactionPack is "4"



  Scenario: I can't create a Transaction pack with a user that don't exist
    Given I have the list of entities:
      |      Model       |               Attrs              |
      | TransactionPack  | {"user_guid":"111","guid":"111"} |
      | TransactionPack  | {"user_guid":"222","guid":"222"} |
      | TransactionPack  | {"user_guid":"333","guid":"333"} |
      | TransactionPack  | {"user_guid":"444","guid":"444"} |
    And the User with the following:
      | Guid | Name |
      | 1111 | test |
    And I send a POST request to "/api/v1/transaction_packs/" with the following:
      | transaction_pack |   {"sync_pack":[{"action":"c","row_guid":"1111"},{"action":"u","row_guid":"2222"},{"action":"d","row_guid":"3333"}]}   |
      | user_guid        |   2222   |
    Then the response status should be "400"
    And the quantity of TransactionPack is "4"



  Scenario: I can create a Transaction pack with a user that exist
    Given I have the list of entities:
      |      Model       |               Attrs              |
      | TransactionPack  | {"user_guid":"111","guid":"111"} |
      | TransactionPack  | {"user_guid":"222","guid":"222"} |
      | TransactionPack  | {"user_guid":"333","guid":"333"} |
      | TransactionPack  | {"user_guid":"444","guid":"444"} |
    And the User with the following:
      | Guid | Name |
      | 1111 | test |
    And I send a POST request to "/api/v1/transaction_packs/" with the following:
      | transaction_pack |   {"sync_pack":[{"action":"c","row_guid":"1111"},{"action":"u","row_guid":"2222"},{"action":"d","row_guid":"3333"}]}   |
      | user_guid        |   1111   |
    Then the response status should be "200"
    And the quantity of TransactionPack is "5"



  Scenario: I can update a Transaction pack
    Given the TransactionPack with the following:
      | Guid | User_guid |
      | 1111 |    2222   |
    And the User with the following:
      | Guid | Name |
      | 2222 | test |
    When I send a PUT request to "/api/v1/transaction_packs/2222" with the following:
      | sync_pack |   [{"action":"c","row_guid":"0000"},{"action":"u","row_guid":"2222"},{"action":"d","row_guid":"3333"}]   |
    Then the response status should be "200"
    And the TransactionPack should have "user_guid" field with value "2222"
    And the TransactionPack should have "guid" field with value "1111"
    And the quantity of Transaction is "3"
    And the Transaction should have "1" records in DB with field "row_guid" and value "0200"



  Scenario: I can't update a Transaction pack without a user
    Given the TransactionPack with the following:
      | Guid | User_guid |
      | 1111 |    2222   |
    When I send a PUT request to "/api/v1/transaction_packs/0" with the following:
      | sync_pack |   [{"action":"c","row_guid":"0000"},{"action":"u","row_guid":"2222"},{"action":"d","row_guid":"3333"}]   |
    Then the response status should be "400"



  Scenario: I can get the last Transaction guid from the Transaction pack
    Given the TransactionPack with the following:
      | Guid | User_guid |
      | 1111 |    2222   |
    And I have the list of entities:
      |    Model     |                                     Attrs                                      |
      | Transaction  | {"user_guid":"111","guid":"111", "action":"c", "transaction_pack_guid":"1111"} |
      | Transaction  | {"user_guid":"222","guid":"222", "action":"u", "transaction_pack_guid":"1111"} |
      | Transaction  | {"user_guid":"333","guid":"333", "action":"u", "transaction_pack_guid":"1111"} |
      | Transaction  | {"user_guid":"444","guid":"444", "action":"d", "transaction_pack_guid":"1111"} |
    When I send a GET request to "/api/v1/transaction_packs/2222/last" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have text: "444"