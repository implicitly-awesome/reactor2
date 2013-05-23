class Test
  def self.transaction_pack_update
    transaction_pack = TransactionPack.get(368723017263482297)

    unless transaction_pack
      transaction_pack = TransactionPack.new
      transaction_pack.guid = ModelsExtensions::Extensions.get_guid
      transaction_pack.user = User.find_in_db(368723017263482297)
      transaction_pack.put_in_cache if transaction_pack.save
    end

    transactions = JSON.parse("[{\"action\":\"c\",\"row_guid\":\"1111\"},{\"action\":\"u\",\"row_guid\":\"2222\"},{\"action\":\"d\",\"row_guid\":\"3333\"}]")

    transactions.each do |t|
      transaction = Transaction.new(t)
      transaction.guid = ModelsExtensions::Extensions.get_guid
      transaction.user = User.find_in_db(368723017263482297)
      transaction.transaction_pack = transaction_pack
      transaction.save
      transaction_pack.add_transaction transaction
      binding.pry
    end

    transaction_pack.delete_from_cache
    transaction_pack.put_in_cache
    response_with transaction_pack, get_last_transaction_id(TransactionPack.get(368723017263482297))
  end

  def self.get_last_transaction_id(pack)
    if pack && pack.transactions.any?
      transactions = pack.transactions
      ids = transactions.map(&:guid)
      ids.map{|t| t.to_i}.max.to_s
    else
      nil
    end
  end

  def self.response_with(model, data = 'ok')
    if model.errors.none?
      response = data.to_json
    else
      response = model.errors.messages.map {|k,v| "#{k}: #{v}"}
    end
  end

end