collection @transaction_packs

attributes :guid
child(:transactions) {attributes :guid, :action, :table, :row_id, :attrs, :handled}