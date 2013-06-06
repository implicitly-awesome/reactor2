Reactor2::App.helpers do
  def get_last_transaction_id(pack)
    if pack && pack.transactions && pack.transactions.any?
      transactions = pack.transactions
      ids = transactions.map(&:guid)
      ids.map{|t| t.to_i}.max
    else
      nil
    end
  end

  def get_last_transaction(pack)
    if pack && pack.transactions && pack.transactions.any?
      pack.transactions.where(guid:get_last_transaction_id(pack)).first.to_json_rabl
    else
      nil
    end
  end
end
