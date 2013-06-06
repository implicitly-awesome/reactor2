object @transaction_pack

attributes :users_guid
child(:transactions) {attributes :guid, :action, :coll_name, :coll_row_guid, :attrs, :handled}