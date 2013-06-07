Reactor2::App.controllers :user do
  before {content_type :json}
  #before :restrict_access
  before :show do
    @user = User.get(params[:guid])
  end

  # Get the list of users
  # DEPRECATED
  get :index, map: '/api/v1/users' do
    #@users = User.all
    #render 'user/index'
    response = 'Deprecated'
  end

  # Get exact user from the list
  get :show, map: '/api/v1/users/:guid' do
    render 'user/show'
  end

  # Create a user
  post :create, map: '/api/v1/users' do
    user = User.new(JSON.parse(params[:user]))
    user.guid = User.get_guid
    user.set_password_digest(user.password)
    if user.save
      user.put_in_cache
      deliver(:user_notifier, :confirmation, user) unless PADRINO_ENV == 'test'
    end
    response_with user, {guid: user.guid.to_s, password_digest: user.password_digest.to_s}
  end

  # Update the user
  put :update, map: '/api/v1/users/:guid' do
    user = User.find_in_db(params[:guid])
    if user && user.update_attributes(JSON.parse(params[:user]))
      user.delete_from_cache
      user.put_in_cache
    end
    response_with user
  end

  # Confirm user who has requested hash, refresh user in cache
  get :confirmation, map: '/api/v1/confirmation/:hashs' do
    # Search for the user by the hashs (confirmation hash-string)
    user = User.where(hashs: params[:hashs])
    # If found someone
    if user.count == 1
      user = user.first
      # Confirm user
      user.confirmed = 1
      # Get hashs nil
      user.hashs = nil
      # Refresh in the cache
      if user.save
        user.delete_from_cache
        user.put_in_cache
      end
    end
    response_with user
  end

  # Delete user from DB and cache
  delete :destroy, map: '/api/v1/users/' do
    user = User.find_in_db(params[:guid])

    # Destroy callback in the user model do not allow you to delete record so for that moment it will be always false
    user.delete_from_cache if user && user.destroy
    response_with user, 'The User can not be deleted!'
  end

  # Get all data for the exact user
  get :full_db, map: '/api/v1/users/:guid/full_db' do
    response = User.find_in_db(params[:guid]).get_all_data
  end

  private

    def restrict_access
      api_key = ApiKey.get(params[:access_token])
      head :unauthorized unless api_key
    end
end
