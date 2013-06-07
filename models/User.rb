require 'digest/sha2'
require 'bcrypt'

class User < ModelsExtensions::Extensions
  include Mongoid::Document

  before_create :set_created_at, :set_updated_at, :set_confirm_hash
  before_update :set_updated_at
  before_save do
    self.email = email.downcase
    self.password = nil
  end
  # User destroying is canceled
  before_destroy {false}


  field :users_guid, as: :guid, type: Integer
  field :users_alias, as: :alias, type: String
  field :users_login, as: :login, type: String
  field :name, as: :name, type: String
  field :password, as: :password, type: String
  field :users_pwd, as: :password_digest, type: String
  field :users_email, as: :email, type: String
  field :users_birthday, as: :birthday, type: Date
  field :users_is_confirmed, as: :confirmed, type: Integer, default: 0
  field :users_hash, as: :hashs, type: String
  field :users_create_dt, as: :created_at, type: DateTime
  field :users_timestamp, as: :updated_at, type: DateTime


  attr_accessible :guid, :alias, :login, :name, :password, :email, :birthday, :confirmed, :hashs
  attr_readonly :password_digest


  validates :guid, uniqueness: true, presence: true
  validates :name, presence: true
  validates :confirmed, inclusion: [0,1]
  validates :alias, length: {maximum: 1000}
  validates :login, length: {maximum: 100}, uniqueness: {case_sensitive: true}, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: {maximum: 1000}, format: { with: VALID_EMAIL_REGEX }
  validates :password, length: {maximum: 100, minimum: 6}, on: :create

  # set confirmation hash
  def set_confirm_hash
    ticks = (Time.now.to_f*1000)-(Time.new(1970,1,1).to_f*1000)
    self.hashs = Digest::SHA2.hexdigest("#{self.guid}#{self.email}#{ticks}weknowwhatwedo")
    self.confirmed = false
    true
  end

  # get transaction_pack
  def transaction_pack
    TransactionPack.where(users_guid: self.guid).first
  end

  # get the list of transactions
  def transactions
    Transaction.where(transaction_pack_guid: self.guid).first || []
  end

  # get all data by user from DB
  def get_all_data
    data = {user: self}
    models = ModelsExtensions::Extensions.get_all_models
    models.delete(Transaction) # transactions already included in transaction pack
    models.each do |model|
      if model.instance_methods.include?(:users_guid)
        data[model.to_s.underscore.to_sym] = []
        model.where(users_guid: self.guid).each do |obj|
          data[model.to_s.underscore.to_sym] << obj
        end
      end
    end
    data.to_json
  end


  def set_password_digest(password)
    self.password_digest = BCrypt::Password.create(password)
  end


  private

  def set_created_at
    self.created_at = Time.now.getutc
  end

  def set_updated_at
    self.updated_at = Time.now.getutc
  end
end
