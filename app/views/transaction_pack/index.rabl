collection @transaction_packs

attributes :guid, :users_guid
child(:transactions) {attributes :guid, :action, :coll_name, :coll_row_guid, :attrs, :handled}