Feature: Transaction pack API

  Scenario: I can get the list of transaction packs
    Given I have the list of entities:
      |      Model       |               Attrs               |
      | TransactionPack  | {"users_guid":"0"} |
      | TransactionPack  | {"users_guid":"1"} |
      | TransactionPack  | {"users_guid":"2"} |
      | TransactionPack  | {"users_guid":"3"} |
    And I send a GET request to "/api/v1/transaction_packs/" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..users_guid" with a length: "4"



  Scenario: I can get exact Transaction pack
    Given I have the list of entities:
      |      Model       |               Attrs               |
      | TransactionPack  | {"users_guid":"0"} |
      | TransactionPack  | {"users_guid":"1"} |
      | TransactionPack  | {"users_guid":"2"} |
      | TransactionPack  | {"users_guid":"3"} |
    And I send a GET request to "/api/v1/transaction_packs/1" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..users_guid" with a length: "1"
    And the JSON response should have text: "1"



  Scenario: I can create a Transaction pack with a user that exist
    Given I have the list of entities:
      | Model  |                                             Attrs                                                  |
      |  User  | {"guid":"0","login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"1","login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"2","login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"3","login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"4","login":"user5","password":"123456","name":"U u5","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I have the list of entities:
      |      Model       |               Attrs               |
      | TransactionPack  | {"users_guid":"0"} |
      | TransactionPack  | {"users_guid":"1"} |
      | TransactionPack  | {"users_guid":"2"} |
      | TransactionPack  | {"users_guid":"3"} |
    And I send a PUT request to "/api/v1/transaction_packs/4" with the following:
      | sync_pack |   [{"action":"c","coll_row_guid":"1111","coll_name":"some_collection"},{"action":"u","coll_row_guid":"2222","coll_name":"some_collection"},{"action":"d","coll_row_guid":"3333","coll_name":"some_collection"}]   |
    Then the response status should be "200"
    And there are 5 TransactionPack records in the Database
    And there are 1 TransactionPack records in the Cache



  Scenario: I can update a Transaction pack with a user that exist
    Given I have the list of entities:
      | Model  |                                             Attrs                                                  |
      |  User  | {"guid":"0","login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"1","login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"2","login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":"3","login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I have the list of entities:
      |      Model       |               Attrs               |
      | TransactionPack  | {"users_guid":"0"} |
      | TransactionPack  | {"users_guid":"1"} |
      | TransactionPack  | {"users_guid":"2"} |
      | TransactionPack  | {"users_guid":"3"} |
    And I send a PUT request to "/api/v1/transaction_packs/2" with the following:
      | sync_pack | [{"action":"c","coll_row_guid":"7777","coll_name":"some_collection"}] |
    Then the response status should be "200"
    And there are 4 TransactionPack records in the Database



  Scenario: I can get the last transaction guid from the transaction pack
    Given I have the list of entities:
      | Model  |                                             Attrs                                                  |
      |  User  | {"guid":"0","login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I have the list of entities:
      |      Model       |       Attrs       |
      | TransactionPack  | {"users_guid":"0"} |
    And I send a PUT request to "/api/v1/transaction_packs/0" with the following:
      | sync_pack | [{"action":"c"},{"action":"u"},{"action":"u"},{"action":"d"}] |
    Then there are 1 TransactionPack records in the Database
    And the response status should be "200"
    And I send a GET request to "/api/v1/transaction_packs/0/last" with the following:
      |||
    And the response status should be "200"
    And the JSON response should have text: "d"