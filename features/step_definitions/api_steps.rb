require 'jsonpath'
require 'nokogiri'

if defined?(Rack)

  # Monkey patch Rack::MockResponse to work properly with response debugging
  class Rack::MockResponse
    def to_str
      body
    end
  end

  World(Rack::Test::Methods)

end

Given /^I set headers:$/ do |headers|
  headers.rows_hash.each {|k,v| header k, v }
end

Given /^I send and accept (XML|JSON)$/ do |type|
  header 'Accept', "application/#{type.downcase}"
  header 'Content-Type', "application/#{type.downcase}"
end

Given /^I send and accept HTML$/ do
  header 'Accept', "text/html"
  header 'Content-Type', "application/x-www-form-urlencoded"
end

When /^I authenticate as the user "([^"]*)" with the password "([^"]*)"$/ do |user, pass|
  authorize user, pass
end

When /^I digest\-authenticate as the user "(.*?)" with the password "(.*?)"$/ do |user, pass|
  digest_authorize user, pass
end

When /^I send a ([^"]*) request (?:for|to) "([^"]*)"(?: with the following:)?$/ do |request_type, path, input|
  request_opts = {method: request_type.downcase.to_sym}

  unless input.nil?
    if input.class == Cucumber::Ast::Table
      request_opts[:params] = input.rows_hash
    else
      request_opts[:input] = input
    end
  end
  request path, request_opts
end

Then /^show me the response$/ do
  if last_response.headers['Content-Type'] =~ /json/
    json_response = JSON.parse(last_response.body)
    puts JSON.pretty_generate(json_response)
  elsif last_response.headers['Content-Type'] =~ /xml/
    puts Nokogiri::XML(last_response.body)
  else
    puts last_response.headers
    puts last_response.body
  end
end

Then /^the response status should be "([^"]*)"$/ do |status|
  if self.respond_to? :should
    last_response.status.should == status.to_i
  else
    assert_equal status.to_i, last_response.status
  end
end

Then(/^the JSON response should (not)?\s?have "([^"]*)" field$/) do |negative, json_path|
  json    = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s).join(' ')
  if negative.present?
    results.length.should_not > 0
  else
    results.length.should > 0
  end
end

Then /^the JSON response should (not)?\s?have "([^"]*)" with the text "([^"]*)"$/ do |negative, json_path, text|
  json    = JSON.parse(last_response.body)
  #results = JsonPath.new(json_path).on(json).to_a.map(&:to_s)
  results = JsonPath.new(json_path).on(json).to_a.map(&:to_s).join(' ')
  if self.respond_to?(:should)
    if negative.present?
      results.should_not include(text)
    else
      results.should include(text)
    end
  else
    if negative.present?
      assert !results.include?(text)
    else
      assert results.include?(text)
    end
  end
end

Then /^the XML response should have "([^"]*)" with the text "([^"]*)"$/ do |xpath, text|
  parsed_response = Nokogiri::XML(last_response.body)
  elements = parsed_response.xpath(xpath)
  if self.respond_to?(:should)
    elements.should_not be_empty, "could not find #{xpath} in:\n#{last_response.body}"
    elements.find { |e| e.text == text }.should_not be_nil, "found elements but could not find #{text} in:\n#{elements.inspect}"
  else
    assert !elements.empty?, "could not find #{xpath} in:\n#{last_response.body}"
    assert elements.find { |e| e.text == text }, "found elements but could not find #{text} in:\n#{elements.inspect}"
  end
end

Then 'the JSON response should be:' do |json|
  expected = JSON.parse(json)
  actual = JSON.parse(last_response.body)

  if self.respond_to?(:should)
    actual.should == expected
  else
    assert_equal actual, response
  end
end

Then /^the JSON response should (not)?\s?be: "([^"]*)"$/ do |negative, json|
  expected = JSON.parse(json)
  actual = JSON.parse(last_response.body)

  if negative.present?
    actual.should_not == expected
  else
    actual.should == expected
  end
end

Then /^the JSON response should (not)?\s?have text: "([^"]*)"$/ do |negative, text|
  #actual = JSON.parse(last_response.body).to_s
  actual = last_response.body.to_s

  if negative.present?
    actual.should_not include(text)
  else
    actual.should include(text)
  end
end

Then /^the JSON response should have "([^"]*)" with a length: "([^"]*)"$/ do |json_path, length|
  json = JSON.parse(last_response.body)
  results = JsonPath.new(json_path).on(json)
  if length == '>0'
    results.length.should > 0
  else
    results.length.should == length.to_i
  end
end

Given(/^the User with the following:$/) do |table|
  table.map_headers!('Guid' => :guid, 'Name' => :name)
  table.hashes.each do |h|
    @user = User.create(h)
    @user.put_in_cache
  end
end

Then(/^the ([^"]*) should have "([^"]*)" field with value "([^"]*)"$/) do |model_name, field, value|
  cls = Object.const_get(model_name)
  obj = nil
  inst = self.instance_variable_get("@#{model_name.underscore}")

  if model_name == 'TransactionPack'
    obj = cls.send(:get, inst.send(:users_guid))
  else
    obj = cls.send(:get, inst.send(:guid))
  end

  obj.send(field.to_sym).should == value
end

Then(/^the ([^"]*) should (not)?\s?exists in ([^"]*)$/) do |model_name, negative, store|
  cls = Object.const_get(model_name)
  obj = nil
  inst = self.instance_variable_get("@#{model_name.downcase}")

  if store == 'CACHE'
    if model_name == 'TransactionPack'
      obj = cls.send(:find_in_cache, inst.send(:users_guid))
    else
      obj = cls.send(:find_in_cache, inst.send(:guid))
    end
  elsif store == 'DB'
    if model_name == 'TransactionPack'
      obj = cls.send(:find_in_db, inst.send(:users_guid))
    else
      obj = cls.send(:find_in_db, inst.send(:guid))
    end
  else
    obj = nil
  end

  if negative.present?
    obj.should == nil
  else
    obj.should_not == nil
  end
end

Given(/^I have the list of entities:$/) do |table|
  table.map_headers!('Model' => :model, 'Attrs' => :attrs)
  i = 0
  table.hashes.each do |h|
    cls = Object.const_get(h[:model])
    obj = cls.new(JSON.parse(h[:attrs]))
    #if h[:model] == 'TransactionPack'
    #  obj.users_guid = i
    #else
    #  obj.guid = i
    #end
    #i = i + 1
    obj.save
  end
end

Given(/^the TransactionPack with the following:$/) do |table|
  table.map_headers!('Guid' => :guid, 'User_guid' => :users_guid)
  table.hashes.each do |h|
    @transaction_pack = TransactionPack.create(h)
    @transaction_pack.put_in_cache
  end
end

When(/^the ([^"]*) should (not)?\s?have "(\d+)" records in DB with field "([^"]*)" and value "([^"]*)"$/) do |model_name, negative, count, field, value|
  cls = Object.const_get(model_name)
  objs = []
  objs << cls.send(:where, {field.to_sym => value})

  if negative.present?
    objs.count.should_not == count.to_i
  else
    objs.count.should == count.to_i
  end
end

Given(/^the Transaction with the following:$/) do |table|
  table.map_headers!('Guid' => :guid, 'User_guid' => :users_guid, 'Action' => :action)
  table.hashes.each do |h|
    @transaction = Transaction.create(h)
    @transaction.put_in_cache
  end
end

Then (/^there are (\d+) ([^"]*) records in the (Cache|Database)/) do |count, model_name, storage|
  cls = Object.const_get(model_name)
  objs = cls.all

  if storage == 'Cache'
    quantity = 0
    objs.each do |o|
      if model_name == 'TransactionPack'
        quantity =+ 1 if cls.find_in_cache(o.users_guid)
      else
        quantity =+ 1 if cls.find_in_cache(o.guid)
      end
    end
    quantity.should == count.to_i
  else
    objs.count.should == count.to_i
  end
end