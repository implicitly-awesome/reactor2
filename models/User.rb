class User < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_guid

  field :_id, type: String
  field :name, type: String

  attr_accessible :_id, :name

  validates :_id, uniqueness: true

  has_many :transactions, class_name: 'Transaction', dependent: :destroy
  has_one :transaction_pack, class_name: 'TransactionPack', dependent: :destroy

  private

  def set_guid
    self._id = ModelsExtensions::Extensions.get_guid
  end

end
