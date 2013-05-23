class User < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps


  field :guid, type: String
  field :name, type: String


  attr_accessible :guid, :name


  validates :guid, uniqueness: true, presence: true


  # get transaction_pack
  def transaction_pack
    TransactionPack.where(user_guid: self.guid).first
  end

  # set transaction_pack
  def transaction_pack=(transaction_pack)
    transaction_pack.user = self
    if transaction_pack.save
      transaction_pack.delete_from_cache
      transaction_pack.put_in_cache
    end
  end

  # get the list of transactions
  def transactions
    Transaction.where(transaction_pack_guid: self.guid).first || []
  end

  # add a transaction to the list
  def add_transaction(transaction)
    transaction.user = self
    if transaction.save
      transaction.delete_from_cache
      transaction.put_in_cache
    end
  end

  # delete a transaction from the list
  def delete_transaction(transaction)
    transaction.delete_from_cache if transaction.destroy
  end


end
