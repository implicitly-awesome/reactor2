class TransactionPack < ModelsExtensions::Extensions
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_guid, type: String
  # package of transactions that should be included to transaction_pack
  field :sync_pack, type: Array


  attr_accessible :user_guid, :sync_pack


  validates :user_guid, presence: true

  embeds_many :transactions, inverse_of: :transaction_pack


  # get user
  def user
    User.get(self.user_guid)
  end

  # set user
  def user=(user)
    if user
      self.user_guid = user.guid
    else
      self.user_guid = nil
    end
  end

  # nullify a transaction in the list
  def nullify_transaction(transaction)
    transaction.transaction_pack = nil
    if transaction.save
      transaction.delete_from_cache
      transaction.put_in_cache
    end
  end

  # delete a transaction from the list
  def delete_transaction(transaction)
    transaction.delete_from_cache if transaction.destroy
  end

  # create an transaction pack object from a json string
  def self.create_from_json(json, &block)
    hash = json ? JSON.parse(json) : nil
    if hash
      tp = self.new(hash)

      if User.get(tp.user_guid)
        obj = self.find_in_db(tp.user_guid)
        obj.destroy if obj

        if tp.save
          tp.delete_from_cache
          tp.put_in_cache
          # exec block after save if it was given
          block.call if block_given?
        end

        hash.each do |k, v|
          if v.is_a? Array
            v.each do |i|
              tp.send("#{k}").send(:create!, i)
            end
          end
        end
        tp
      else
        nil
      end
    end
  end
end
