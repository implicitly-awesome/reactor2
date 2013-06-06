require 'rack/auth/digest/md5'

module ModelsExtensions
  class Extensions
    def initialize
      @attributes = {}
    end

    # generate a Guid
    def self.get_guid(datetime=(Time.now.getutc.to_f * 1000.0).to_i, shard=1, id=rand(999))
      zero_date = (Time.new(2012,1,1).getutc.to_f * 1000.0).to_i
      delta_time = (datetime - zero_date)
      guid = (delta_time*(2**23))+((shard%(2**13))*(2**10))+(id%(2**10))
      guid.to_s
    end

    # get a list of the models, described in reactor
    def self.get_all_models
      Object.constants.collect { |sym| Object.const_get(sym) }.
          select { |constant| constant.class == Class && constant.include?(Mongoid::Document) }
    end

    # try to get record from cache (and build from json hash then) or from database
    def self.get(guid)
      begin
        self.find_in_cache(guid) ? build_from_json(self.find_in_cache(guid)) : self.find_in_db(guid)
      rescue
        nil
      end
    end

    def self.find_in_cache(guid)
      if self.to_s == 'TransactionPack'
        Padrino.cache.get("tp_#{guid}")
      else
        Padrino.cache.get(guid)
      end
    end

    def self.find_by_user(user_guid)
      self.where(user_guid: user_guid).first
    end

    def self.find_in_db(guid)
      if self.to_s == 'TransactionPack'
        result = self.find_by_user(guid)
      else
        result = self.where(guid: guid).first
      end
      result.put_in_cache if result
      result
    end

    def to_json_rabl
      json_template_path = "#{Padrino.root}/app/views/#{self.class.to_s.underscore}/show"
      if File.exist? "#{json_template_path}.rabl"
        Rabl.render(self, json_template_path)
      else
        self.to_json
      end
    end

    def put_in_cache
      if self.is_a? TransactionPack
        Padrino.cache.set("tp_#{self.user_guid}", self.to_json_rabl)
      else
        Padrino.cache.set(self.guid, self.to_json_rabl)
      end
    end

    def delete_from_cache
      if self.is_a? TransactionPack
        Padrino.cache.delete("tp_#{self.user_guid}")
      else
        Padrino.cache.delete(self.guid)
      end
    end

    #def method_missing(name, *args)
    #  attribute = name.to_s
    #  if attribute =~ /=$/
    #    @attributes[attribute.chop] = args[0]
    #  else
    #    @attributes[attribute]
    #  end
    #end


    private

    def set_guid
      self.guid = ModelsExtensions::Extensions.get_guid
    end

    def self.build_from_json(json, &block)
      hash = json ? JSON.parse(json) : nil
      if hash
        entity = self.new(hash)

        unless entity.is_a? TransactionPack
          entity.guid = self.get_guid
        end

        if entity.is_a? User
          entity.set_password_digest(entity.password)

          block.call if block_given?

          hash.each do |k, v|
            if v.is_a? Array
              v.each do |i|
                entity.send("#{k}").send(:build, i)
              end
            end
          end
          entity
        else
          if User.get(entity.send(:user_guid))
            block.call if block_given?

            hash.each do |k, v|
              if v.is_a? Array
                v.each do |i|
                  entity.send("#{k}").send(:build, i)
                end
              end
            end
            entity
          else
            nil
          end
        end
      end
    end
  end
end