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

  private

  def set_guid
    self.guid = ModelsExtensions::Extensions.get_guid
  end

end
