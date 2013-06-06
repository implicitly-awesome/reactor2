# Common exception for not founded records
class NoRecordException < Exception
  def initialize(data=nil)
    @data = data
  end

  def to_s
    'NoRecord::Record not found.'
  end
end