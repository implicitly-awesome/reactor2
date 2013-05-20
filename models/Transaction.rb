# transaction from devices for synchronisation with DB
class Transaction < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_guid

  field :_id, type: String
  field :local_id, type: Integer
  field :action, type: String                   # [c]reate || [u]pdate || [d]elete
  field :table, type: String                    # table that transaction for
  field :row_id, type: Integer                  # row ID in the table that transaction for
  field :attrs, type: Hash                     # fields hash for [c]reate or [u]pdate
  field :handled, type: Boolean, default: false # status of the transaction: was handled by Worker or not

  attr_accessible :_id, :action, :table, :row_id, :attrs, :handled

  validates :_id, uniqueness: true
  VALID_ACTION_REGEX = /c|u|d/
  validates :action, presence: true, format: { with: VALID_ACTION_REGEX }

  belongs_to :user, foreign_key: :user_id, class_name: 'User'
  belongs_to :transaction_pack, foreign_key: :transaction_pack_id, class_name: 'TransactionPack'

  def serializable_hash(options={})
    json = {}
    self.instance_values['attributes'].each {|k,v| json[k] = v}
    json
  end
end
