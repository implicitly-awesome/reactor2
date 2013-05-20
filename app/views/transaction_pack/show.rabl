object @transaction_pack

attributes :_id
child(:transactions) {attributes :_id, :action, :table, :row_id, :attrs, :handled}