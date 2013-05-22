Reactor2::App.helpers do

  def get_user(id)
    begin
      User.new(JSON.parse(User.find_in_cache(id)))
    rescue
      User.find_in_db(id)
    end
  end

end
