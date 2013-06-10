class ApiKey < ModelsExtensions::Extensions
  include Mongoid::Document

  field :users_guid, as: :guid, type: String
  field :users_token, as: :token, type: String

  attr_accessible :guid
  attr_readonly :token

  validates :guid, uniqueness: true, presence: true
  validates :token, uniqueness: true, presence: true

  def generate_token
    self.token = SecureRandom.hex
  end
end