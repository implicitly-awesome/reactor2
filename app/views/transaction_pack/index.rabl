collection @transaction_packs

attributes :guid, :user_guid
child(:transactions) {attributes :guid, :action, :coll_name, :coll_row_guid, :attrs, :handled}