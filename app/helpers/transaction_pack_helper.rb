Reactor2::App.helpers do
  def get_last_transaction_id(pack)
    if pack && pack.transactions.any?
      transactions = pack.transactions
      ids = transactions.map(&:guid)
      ids.map{|t| t.to_i}.max.to_s
    else
      nil
    end
  end

  def get_transaction_pack(user_guid)
    begin
      TransactionPack.new(JSON.parse(TransactionPack.find_in_cache(user_guid)))
    rescue
      TransactionPack.find_in_db(user_guid)
    end
  end

  def create_transaction_pack(user_guid)
    transaction_pack = TransactionPack.new
    transaction_pack.user = User.find_in_db(user_guid)
    transaction_pack.put_in_cache
    transaction_pack.save
    transaction_pack
  end
end
