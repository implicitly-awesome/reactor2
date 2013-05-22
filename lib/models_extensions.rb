require 'rack/auth/digest/md5'

module ModelsExtensions
  class Extensions
    def self.get_guid(datetime=(Time.now.getutc.to_f * 1000.0).to_i, shard=1, guid=rand(999))
      zero_date = (Time.new(2012,1,1).getutc.to_f * 1000.0).to_i
      delta_time = (datetime - zero_date)
      guid = (delta_time*(2**23))+((shard%(2**13))*(2**10))+(guid%(2**10))
      guid.to_s
    end

    def self.find_by_user(user_guid)
      self.where("user_guid = '#{user_guid}'").first
    end

    def self.find_in_cache(guid)
      if self.to_s == 'TransactionPack'
        Padrino.cache.get("tp_#{guid}")
      else
        Padrino.cache.get(guid)
      end
    end

    def self.find_in_db(guid)
      if self.to_s == 'TransactionPack'
        result = self.find_by_user(guid)
      else
        result = self.find(guid)
      end
      result.put_in_cache if result
      result
    end

    def put_in_cache
      if self.is_a? TransactionPack
        Padrino.cache.set("tp_#{self.user_guid}", self.to_json)
      else
        Padrino.cache.set(self._id, self.to_json)
      end
    end

    def delete_from_cache
      if self.is_a? TransactionPack
        Padrino.cache.delete("tp_#{self.user_guid}")
      else
        Padrino.cache.delete(self._id)
      end
    end

    private

    def set_guid
      self._id = ModelsExtensions::Extensions.get_guid
    end

  end
end