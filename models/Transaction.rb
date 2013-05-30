# transaction from devices for synchronisation with DB
class Transaction < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  #before_validation {self.guid = ModelsExtensions::Extensions.get_guid}

  field :guid, type: String
  field :user_guid, type: String
  #field :transaction_pack_guid, type: String
  field :action, type: String                   # [c]reate || [u]pdate || [d]elete
  field :table, type: String                    # table that transaction for
  field :row_guid, type: String                  # row ID in the table that transaction for
  field :attrs, type: Hash                     # fields hash for [c]reate or [u]pdate
  field :handled, type: Boolean, default: false # status of the transaction: was handled by Worker or not


  attr_accessible :guid, :user_guid, :action, :table, :row_guid, :attrs, :handled#, :transaction_pack_guid


  validates :guid, uniqueness: true, presence: true
  validates :user_guid, presence: true
  VALID_ACTION_REGEX = /c|u|d/
  validates :action, presence: true, format: { with: VALID_ACTION_REGEX }

  embedded_in :transaction_pack, inverse_of: :transactions


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

  ## get transaction_pack
  #def transaction_pack
  #  TransactionPack.get(self.transaction_pack_guid)
  #end
  #
  ## set transaction_pack
  #def transaction_pack=(transaction_pack)
  #  if transaction_pack
  #    self.transaction_pack_guid = transaction_pack.guid
  #  else
  #    self.transaction_pack_guid = nil
  #  end
  #end

end
