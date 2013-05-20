# transactions pack from devices for synchronisation with DB
class TransactionPack < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_guid

  field :_id, type: String
  field :sync_pack, type: Array

  attr_accessible :_id, :sync_pack

  validates :_id, uniqueness: true

  belongs_to :user, foreign_key: :user_id, class_name: 'User'
  has_many :transactions, class_name: 'Transaction', dependent: :nullify

  def serializable_hash(options={})
    json = {}
    self.instance_values['attributes'].each {|k,v| json[k] = v}
    json[:transactions] = transactions.inject([]) { |acc, t| acc << t.serializable_hash; acc }
    json
  end
end
