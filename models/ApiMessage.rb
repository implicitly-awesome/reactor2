class ApiMessage

  def initialize(message, type=:info)
    case type
      when :error then @type = 'ERR'
      when :warning then @type = 'WRN'
      when :success then @type = 'SCCS'
      else self.type = 'INFO'
    end
    self.message = message
  end

  attr_accessor :type, :message
end