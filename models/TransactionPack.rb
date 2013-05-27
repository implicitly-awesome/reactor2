class TransactionPack < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps


  field :guid, type: String
  field :user_guid, type: String
  # package of transactions that should be included to transaction_pack
  field :sync_pack, type: Array


  attr_accessible :guid, :user_guid, :sync_pack


  validates :guid, uniqueness: true, presence: true
  validates :user_guid, presence: true


  # get user
  def user
    User.get(self.user_guid)
  end

  # set user
  def user=(user)
    if user
      self.user_guid = user.guid
    else
      self.user_guid = nil
    end
  end

  # get the list of transactions
  def transactions
    Transaction.where(transaction_pack_guid: self.guid) || []
  end

  # add a transaction to the list
  def add_transaction(transaction)
    transaction.transaction_pack = self
    if transaction.save
      transaction.delete_from_cache
      transaction.put_in_cache
    end
  end

  # nullify a transaction in the list
  def nullify_transaction(transaction)
    transaction.transaction_pack = nil
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
