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
end
