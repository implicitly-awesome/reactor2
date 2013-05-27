Feature: User API

  Scenario: I can get the list of Users
    Given I have the list of entities:
      | Model |             Attrs             |
      | User  | {"name":"test1","guid":"111"} |
      | User  | {"name":"test2","guid":"222"} |
      | User  | {"name":"test3","guid":"333"} |
      | User  | {"name":"test4","guid":"444"} |
    And I send a GET request to "/api/v1/users/" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "4"



  Scenario: I can get exact User
    Given I have the list of entities:
      | Model |             Attrs             |
      | User  | {"name":"test1","guid":"111"} |
      | User  | {"name":"test2","guid":"222"} |
      | User  | {"name":"test3","guid":"333"} |
      | User  | {"name":"test4","guid":"444"} |
    And I send a GET request to "/api/v1/users/333" with the following:
      |||
    Then the response status should be "200"
    And the JSON response should have "$..guid" with a length: "1"
    And the JSON response should have text: "test3"
    And the JSON response should have text: "333"



  Scenario: I can't create a User without a name
    Given I have the list of entities:
      | Model |             Attrs             |
      | User  | {"name":"test1","guid":"111"} |
      | User  | {"name":"test2","guid":"222"} |
      | User  | {"name":"test3","guid":"333"} |
      | User  | {"name":"test4","guid":"444"} |
    And I send a POST request to "/api/v1/users/" with the following:
      | user |   {"name":""}   |
    Then the response status should be "400"
    And the quantity of User is "4"



  Scenario: I can create a User with a name
    Given I have the list of entities:
      | Model |             Attrs             |
      | User  | {"name":"test1","guid":"111"} |
      | User  | {"name":"test2","guid":"222"} |
      | User  | {"name":"test3","guid":"333"} |
      | User  | {"name":"test4","guid":"444"} |
    And I send a POST request to "/api/v1/users/" with the following:
      | user |   {"name":"test"}   |
    Then the response status should be "200"
    And the quantity of User is "5"



  Scenario: I can update a User
    Given the User with the following:
      | Guid | Name |
      | 1111 | test |
    When I send a PUT request to "/api/v1/users/1111" with the following:
      | user |   {"name":"test2"}   |
    Then the response status should be "200"
    And the User should have "name" field with value "test2"



  Scenario: I can't update a User without a name
    Given the User with the following:
      | Guid | Name |
      | 1111 | test |
    When I send a PUT request to "/api/v1/users/1111" with the following:
      | user |   {"name":""}   |
    Then the response status should be "400"



  Scenario: I can't delete User (delete is frozen for a while)
    Given the User with the following:
      | Guid | Name |
      | 1111 | test |
    When I send a DELETE request to "/api/v1/users/" with the following:
      | guid |   1111   |
    Then the response status should be "200"
    And the User should not exists in CACHE
    And the User should exists in DB
