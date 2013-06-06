Feature: User API

  Scenario: I can't get the list of users
    Given I have the list of entities:
      | Model  |                                                  Attrs                                                      |
      |  User  | {"guid":0,"login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":1,"login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":2,"login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":3,"login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I send a GET request to "/api/v1/users/" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have text: "Deprecated"



  Scenario: I can get the exact user
    Given I have the list of entities:
      | Model  |                                                  Attrs                                                      |
      |  User  | {"guid":0,"login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":1,"login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":2,"login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":3,"login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I send a GET request to "/api/v1/users/2" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..login" with a length: "1"
    And the JSON response should have text: "user3"



  Scenario: I can create a user
    Given I have the list of entities:
      | Model  |                                                  Attrs                                                      |
      |  User  | {"guid":0,"login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":1,"login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":2,"login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":3,"login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I send a POST request to "/api/v1/users/" with the following:
      | user | {"login":"user5","password":"123456","name":"U u5","email":"chernih_av@bk.ru","confirmed":"false"} |
    Then the response status should be "200"
    And the JSON response should have text: "SCCS"
    And there are 5 User records in the Database
    And there are 1 User records in the Cache



  Scenario: I can update a user
    Given I have the list of entities:
      | Model  |                                                  Attrs                                                      |
      |  User  | {"guid":0,"login":"user1","password":"123456","name":"U u1","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":1,"login":"user2","password":"123456","name":"U u2","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":2,"login":"user3","password":"123456","name":"U u3","email":"chernih_av@bk.ru","confirmed":"false"} |
      |  User  | {"guid":3,"login":"user4","password":"123456","name":"U u4","email":"chernih_av@bk.ru","confirmed":"false"} |
    And I send a PUT request to "/api/v1/users/1" with the following:
      | user | {"name":"TEST"} |
    Then the response status should be "200"
    And the JSON response should have text: "SCCS"
    And there are 4 User records in the Database
    And there are 1 User records in the Cache
    And I send a GET request to "/api/v1/users/1" with the following:
      |||
    And the JSON response should have "$..login" with a length: "1"
    And the JSON response should have text: "user2"
    And the JSON response should have text: "TEST"