object @transaction_pack

attributes :guid, :user_guid
child(:transactions) {attributes :guid, :action, :coll_name, :coll_row_id, :attrs, :handled}