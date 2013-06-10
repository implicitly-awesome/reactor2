# Transaction from devices for synchronisation with DB
class Transaction < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  field :guid, type: String
  field :users_guid, type: String
  field :action, type: String                   # [c]reate || [u]pdate || [d]elete
  field :coll_name, type: String                # collection that transaction for
  field :coll_row_guid, type: Integer            # row ID in the collection that transaction for
  field :attrs, type: Hash                      # fields hash for [c]reate or [u]pdate
  field :handled, type: Boolean, default: false # status of the transaction: was handled by Worker or not


  attr_accessible :guid, :users_guid, :action, :coll_name, :coll_row_guid, :attrs, :handled


  validates :guid, uniqueness: true, presence: true
  VALID_ACTION_REGEX = /c|u|d/
  validates :action, presence: true, format: { with: VALID_ACTION_REGEX }

  embedded_in :transaction_pack, inverse_of: :transactions

  # Get user
  def user
    User.get(self.users_guid)
  end

  # Set user
  def user=(user)
    if user
      self.users_guid = user.guid
    else
      self.users_guid = nil
    end
  end
end
