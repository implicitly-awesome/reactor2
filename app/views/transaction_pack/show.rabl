object @transaction_pack

attributes :user_guid
child(:transactions) {attributes :guid, :action, :coll_name, :coll_row_id, :attrs, :handled}