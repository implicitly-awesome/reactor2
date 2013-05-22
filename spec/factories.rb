require 'factory_girl'

FactoryGirl.define do

  factory :user do
    after :create do |u|
      u._id = '007'
    end

    _id '007'
    name 'test_user'
  end

  factory :transaction_pack do
    after :create do |tp|
      tp._id = ModelsExtensions::Extensions.get_guid
    end

    sequence(:_id){|n| "#{n}" }
    sync_pack [[{action:'c',row_id:'1111'},{action:'u',row_id:'2222'},{action:'d',row_id:'3333'}]]
    user
  end

  factory :transaction do
    after :create do |t|
      t._id = ModelsExtensions::Extensions.get_guid
    end

    sequence(:_id){|n| "#{n}" }
    action 'c'
    sequence(:row_id){|n| "#{n}" }
    sequence(:local_id){|n| n }
    table "some_table"
    attrs {{field1:'value001',field2:'value002'}}
    handled false
    user
    transaction_pack

    factory :clean do
      handled true
    end
  end

end