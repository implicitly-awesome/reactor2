require 'bcrypt'

Reactor2::App.helpers do
  # Authorize user
  def authorize(user, password)
    #BCrypt::Password.new(user.password_digest) == password
    user.password_digest == Digest::SHA2.hexdigest(password)
  end

  # Check users access by ApiKey
  def has_access?(users_guid, token)
    if users_guid && token
      key = ApiKey.get(users_guid)
      key ? token == key : false
    else
      false
    end
  end
end
