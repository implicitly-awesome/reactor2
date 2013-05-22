object @transaction_pack

attributes :guid
child(:transactions) {attributes :guid, :action, :table, :row_id, :attrs, :handled}