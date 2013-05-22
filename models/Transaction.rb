# transaction from devices for synchronisation with DB
class Transaction < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_guid

  field :guid, type: String
  field :local_id, type: Integer
  field :action, type: String                   # [c]reate || [u]pdate || [d]elete
  field :table, type: String                    # table that transaction for
  field :row_guid, type: Integer                  # row ID in the table that transaction for
  field :attrs, type: Hash                     # fields hash for [c]reate or [u]pdate
  field :handled, type: Boolean, default: false # status of the transaction: was handled by Worker or not

  attr_accessible :guid, :action, :table, :row_id, :attrs, :handled

  validates :guid, uniqueness: true
  VALID_ACTION_REGEX = /c|u|d/
  validates :action, presence: true, format: { with: VALID_ACTION_REGEX }

  belongs_to :user, foreign_key: :user_guid, class_name: 'User'
  belongs_to :transaction_pack, foreign_key: :transaction_pack_guid, class_name: 'TransactionPack'

  def serializable_hash(options={})
    json = {}
    self.instance_values['attributes'].each {|k,v| json[k] = v}
    json
  end
end
