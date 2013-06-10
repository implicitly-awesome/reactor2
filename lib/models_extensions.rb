require 'rack/auth/digest/md5'

# Extensions for the MongoId models and Dalli
module ModelsExtensions
  class Extensions
    def initialize
      @attributes = {}
    end

    # Generate an incremental Guid
    # @param datetime [DateTime] datetime when the record is creating
    # @param shard [Integer] number of the shard where the record is creating
    # @param id [Integer] random integer number that brings some randomization to the method
    # @return [Integer] the guid
    def self.get_guid(datetime=(Time.now.getutc.to_f * 1000.0).to_i, shard=1, id=rand(999))
      zero_date = (Time.new(2012,1,1).getutc.to_f * 1000.0).to_i
      delta_time = (datetime - zero_date)
      (delta_time*(2**23))+((shard%(2**13))*(2**10))+(id%(2**10))
    end

    # Get a list of the models, described in reactor
    # @return [Array] array of classes that represents models of the application
    def self.get_all_models
      Object.constants.collect { |sym| Object.const_get(sym) }.
          select { |constant| constant.class == Class && constant.include?(Mongoid::Document) }
    end

    # Get model object from cache or from database
    # @param guid [String,Integer] guid of the record
    # @return [Class] the object built from cache or got form database
    def self.get(guid)
      guid = guid.to_s
       if self.find_in_cache(guid)
         build_from_json(self.find_in_cache(guid))
       else
         self.find_in_db(guid)
       end
    end

    # Get record from cache
    # @param guid [String,Integer] guid of the record
    # @return [String] JSON representation of the record
    def self.find_in_cache(guid)
      guid = guid.to_s
      if self.to_s == 'TransactionPack'
        Padrino.cache.get("tp_#{guid}")
      else
        Padrino.cache.get(guid)
      end
    end

    # Get record from database by user guid
    # @param users_guid [String,Integer] guid of the user
    # @return [Class] model object of record that belongs to the user
    def self.find_by_user(guid)
      self.where(users_guid:guid.to_s).first
    end

    # Get record from database by guid. If it was founded - put in cache
    # @param guid [String,Integer] guid of the record
    # @return [Class] model object of record
    def self.find_in_db(guid)
      guid = guid.to_s
      if self.to_s == 'TransactionPack'
        result = self.find_by_user(guid)
      else
        result = self.where(guid: guid).first
      end
      result.put_in_cache if result
      result
    end

    # Get JSON representation of the object; JSON generates with Rabl template (seeks in the views directory)
    # @return [String] JSON representation of the object
    def to_json_rabl
      json_template_path = "#{Padrino.root}/app/views/#{self.class.to_s.underscore}/show"
      if File.exist? "#{json_template_path}.rabl"
        Rabl.render(self, json_template_path)
      else
        self.to_json
      end
    end

    # Get a JSON representation of the object and put it into cache
    # @return [Boolean] success of the operation
    def put_in_cache
      if self.is_a? TransactionPack
        Padrino.cache.set("tp_#{self.users_guid.to_s}", self.to_json_rabl)
      else
        Padrino.cache.set(self.guid, self.to_json_rabl)
      end
    end

    # Delete the object from cache.
    # @return [Boolean] success of the operation
    def delete_from_cache
      if self.is_a? TransactionPack
        Padrino.cache.delete("tp_#{self.users_guid.to_s}")
      else
        Padrino.cache.delete(self.guid.to_s)
      end
    end



    private

    # Set guid to the object
    # @return [String] guid
    def set_guid
      self.guid = ModelsExtensions::Extensions.get_guid
    end

    # Build an object from the JSON string
    # @param json [String] a JSON representation of the object
    # @param block [Proc] a block that will be execute during the object building
    # @return [Class] the object
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
          if User.get(entity.send(:users_guid))
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