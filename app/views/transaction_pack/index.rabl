collection @transaction_packs

attributes :_id
child(:transactions) {attributes :_id, :action, :table, :row_id, :attrs, :handled}