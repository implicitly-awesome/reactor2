Reactor2::App.helpers do

  def get_user(guid)
    begin
      User.new(JSON.parse(User.find_in_cache(guid)))
    rescue
      User.find_in_db(guid)
    end
  end

end
