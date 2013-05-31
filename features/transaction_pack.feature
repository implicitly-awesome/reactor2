#Feature: Transaction pack API
#
#  Scenario: I can get the list of Transaction packs
#    Given I have the list of entities:
#      |  Model |               Attrs            |
#      |  User  | {"name":"test1","guid":"1111"} |
#      |  User  | {"name":"test2","guid":"2222"} |
#      |  User  | {"name":"test3","guid":"3333"} |
#      |  User  | {"name":"test4","guid":"4444"} |
#    And I have the list of entities:
#      |      Model       |               Attrs               |
#      | TransactionPack  | {"user_guid":"1111","guid":"111"} |
#      | TransactionPack  | {"user_guid":"2222","guid":"222"} |
#      | TransactionPack  | {"user_guid":"3333","guid":"333"} |
#      | TransactionPack  | {"user_guid":"4444","guid":"444"} |
#    And I send a GET request to "/api/v1/transaction_packs/" with the following:
#      |||
#    Then the response status should be "200"
#    And the JSON response should have "$..guid" with a length: "4"
#
#
#
#  Scenario: I can get exact Transaction pack
#    Given I have the list of entities:
#      |  Model |               Attrs            |
#      |  User  | {"name":"test1","guid":"1111"} |
#      |  User  | {"name":"test2","guid":"2222"} |
#      |  User  | {"name":"test3","guid":"3333"} |
#      |  User  | {"name":"test4","guid":"4444"} |
#    And I have the list of entities:
#      |      Model       |               Attrs               |
#      | TransactionPack  | {"user_guid":"1111","guid":"111"} |
#      | TransactionPack  | {"user_guid":"2222","guid":"222"} |
#      | TransactionPack  | {"user_guid":"3333","guid":"333"} |
#      | TransactionPack  | {"user_guid":"4444","guid":"444"} |
#    And I send a GET request to "/api/v1/transaction_packs/1111" with the following:
#      |||
#    Then the response status should be "200"
#    And the JSON response should have "$..guid" with a length: "1"
#    And the JSON response should have text: "222"
#
#
#
#  Scenario: I can't create a Transaction pack without a user
#    Given I have the list of entities:
#      |  Model |               Attrs            |
#      |  User  | {"name":"test1","guid":"1111"} |
#      |  User  | {"name":"test2","guid":"2222"} |
#      |  User  | {"name":"test3","guid":"3333"} |
#      |  User  | {"name":"test4","guid":"4444"} |
#    And I have the list of entities:
#      |      Model       |               Attrs               |
#      | TransactionPack  | {"user_guid":"1111","guid":"111"} |
#      | TransactionPack  | {"user_guid":"2222","guid":"222"} |
#      | TransactionPack  | {"user_guid":"3333","guid":"333"} |
#      | TransactionPack  | {"user_guid":"4444","guid":"444"} |
#    And the User with the following:
#      | Guid | Name |
#      | 1111 | test |
#    And I send a PUT request to "/api/v1/transaction_packs/" with the following:
#      | sync_pack |   [{"action":"c"},{"action":"u"},{"action":"d"}]   |
#    Then the response status should be "405"
#    And the quantity of TransactionPack is "4"
#
#
#
#  Scenario: I can't create a Transaction pack with a user that don't exist
#    Given I have the list of entities:
#      |  Model |               Attrs            |
#      |  User  | {"name":"test1","guid":"1111"} |
#      |  User  | {"name":"test2","guid":"2222"} |
#      |  User  | {"name":"test3","guid":"3333"} |
#      |  User  | {"name":"test4","guid":"4444"} |
#    And I have the list of entities:
#      |      Model       |               Attrs               |
#      | TransactionPack  | {"user_guid":"1111","guid":"111"} |
#      | TransactionPack  | {"user_guid":"2222","guid":"222"} |
#      | TransactionPack  | {"user_guid":"3333","guid":"333"} |
#      | TransactionPack  | {"user_guid":"4444","guid":"444"} |
#    And the User with the following:
#      | Guid | Name |
#      | 1111 | test |
#    And I send a PUT request to "/api/v1/transaction_packs/2222" with the following:
#      | sync_pack |   [{"action":"c"},{"action":"u"},{"action":"d"}]   |
#    Then the response status should be "400"
#    And the quantity of TransactionPack is "4"
#
#
#
#  Scenario: I can create a Transaction pack with a user that exist
#    Given I have the list of entities:
#      |  Model |               Attrs            |
#      |  User  | {"name":"test1","guid":"1111"} |
#      |  User  | {"name":"test2","guid":"2222"} |
#      |  User  | {"name":"test3","guid":"3333"} |
#      |  User  | {"name":"test4","guid":"4444"} |
#    And I have the list of entities:
#      |      Model       |               Attrs               |
#      | TransactionPack  | {"user_guid":"1111","guid":"111"} |
#      | TransactionPack  | {"user_guid":"2222","guid":"222"} |
#      | TransactionPack  | {"user_guid":"3333","guid":"333"} |
#      | TransactionPack  | {"user_guid":"4444","guid":"444"} |
#    And I send a PUT request to "/api/v1/transaction_packs/1111" with the following:
#      | sync_pack |   [{"action":"c"},{"action":"u"},{"action":"d"}]   |
#    Then the response status should be "200"
#    And the quantity of TransactionPack is "5"
#
#
#
#  Scenario: I can update a Transaction pack
#    Given the User with the following:
#      | Guid | Name |
#      | 2222 | test |
#    And the TransactionPack with the following:
#      | Guid | User_guid |
#      | 1111 |    2222   |
#    When I send a PUT request to "/api/v1/transaction_packs/2222" with the following:
#      | sync_pack |   [{"action":"c"},{"action":"u"},{"action":"d"}]   |
#    Then the response status should be "200"
#    And the TransactionPack should have "user_guid" field with value "2222"
#    And the TransactionPack should have "guid" field with value "1111"
#    And the quantity of Transaction is "3"
#    And the Transaction should have "1" records in DB with field "row_guid" and value "0200"
#
#
#
#  Scenario: I can't update a Transaction pack without a user
#    Given the TransactionPack with the following:
#      | Guid | User_guid |
#      | 1111 |    2222   |
#    When I send a PUT request to "/api/v1/transaction_packs/0" with the following:
#      | sync_pack |   [{"action":"c"},{"action":"u"},{"action":"d"}]   |
#    Then the response status should be "400"