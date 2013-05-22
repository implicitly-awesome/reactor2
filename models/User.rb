class User < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_guid

  field :guid, type: String
  field :name, type: String

  attr_accessible :guid, :name

  validates :guid, uniqueness: true

  has_many :transactions, class_name: 'Transaction', dependent: :destroy
  has_one :transaction_pack, class_name: 'TransactionPack', dependent: :destroy

  def serializable_hash(options={})
    json = {}
    self.instance_values['attributes'].each {|k,v| json[k] = v}
    #json[:transactions] = transactions.inject([]) { |acc, t| acc << t.serializable_hash; acc }
    json
  end

end
