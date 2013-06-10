class Country < ModelsExtensions::Extensions
  include Mongoid::Document

  before_create :set_created_at, :set_updated_at
  before_update :set_updated_at

  store_in session: :nsi

  field :countries_guid, as: :guid, type: String
  field :countries_name, as: :name, type: String
  field :countries_create_dt, as: :created_at, type: DateTime
  field :countries_timestamp, as: :updated_at, type: DateTime

  attr_accessible :guid, :name, :created_at, :updated_at

  validates :guid, presence: true
  validates :name, length: {maximum: 100}


  private

  def set_created_at
    self.created_at = Time.now.getutc
  end

  def set_updated_at
    self.updated_at = Time.now.getutc
  end
end