require 'digest/sha2'
require 'bcrypt'
require 'mongo'

class User < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  before_create :set_confirm_hash
  before_save do
    self.email = email.downcase
    self.password = nil
  end
  # User destroying is canceled
  before_destroy {false}


  field :guid, type: String
  field :alias, type: String
  field :login, type: String
  field :password, type: String
  field :password_digest, type: String
  field :email, type: String
  field :birthday, type: Date
  field :confirmed, type: Integer, default: 0
  field :confirm_hash, type: String

  attr_accessible :guid, :alias, :login, :name, :password, :password_digest, :email, :birthday, :confirmed, :confirm_hash
  #attr_readonly :password_digest


  validates :guid, uniqueness: true, presence: true
  validates :confirmed, inclusion: [0,1,'0','1']
  validates :alias, length: {maximum: 1000}
  validates :login, length: {maximum: 100}, uniqueness: {case_sensitive: true}, presence: true
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: {maximum: 1000}, format: { with: VALID_EMAIL_REGEX }
  validates :password, length: {maximum: 100, minimum: 6}, on: :create

  # find user by login
  def self.find_by_login(login)
    User.where(login: login).first
  end

  # set confirmation hash
  def set_confirm_hash
    ticks = (Time.now.to_f*1000)-(Time.new(1970,1,1).to_f*1000)
    self.confirm_hash = Digest::SHA2.hexdigest("#{self.guid}#{self.email}#{ticks}weknowwhatwedo")
    self.confirmed = false
    true
  end

  # get all data by user from DB
  def get_all_data
    db = Mongo::MongoClient.new('ec2-54-244-143-34.us-west-2.compute.amazonaws.com', '27017').db('improva')
    data = {user: self}
    models = Mongoid.default_session.collections.map(&:name)
    #models = ModelsExtensions::Extensions.get_all_models

    models.delete('transactions') # transactions already included in transaction pack
    models.delete('transaction_packs')
    models.delete('users')
    models.delete('tutorcriteria')
    models.delete('tutors')
    models.delete('tutorgoals')

    # return whole data for collections in white list
    white_list = ['tutorcriteria', 'tutors', 'tutorgoals']

    models.each do |model|
      #data[model.to_s.underscore.to_sym] = []
      data[model] = []
      #model.where(user_guid: self.guid).each do |obj|
      #  data[model.to_s.underscore.to_sym] << obj
      #end

      db[model].find({"user_guid" => self.guid}).to_a.each do |obj|
        data[model] << obj
      end
    end

    white_list.each do |model|
      data[model] = []

      db[model].find({}).to_a.each do |obj|
        data[model] << obj
      end
    end


    data.to_json
  end


  def set_password_digest(password)
    #self.password_digest = BCrypt::Password.create(password)
    self.password_digest = Digest::SHA2.hexdigest(password)
  end
end
