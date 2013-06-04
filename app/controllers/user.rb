Reactor2::App.controllers :user do
  before {content_type :json}
  before :restrict_access
  before :show do
    @user = User.get(params[:guid])
  end

  # get the list of users
  get :index, map: '/api/v1/users' do
    @users = User.all
    render 'user/index'
  end

  # get exact user from the list
  get :show, map: '/api/v1/users/:guid' do
    render 'user/show'
  end

  # create a user
  post :create, map: '/api/v1/users' do
    user = User.new(JSON.parse(params[:user]))
    user.guid = User.get_guid
    user.set_password_digest(user.password)
    if user.save
      user.put_in_cache
      deliver(:user_notifier, :confirmation, user)
    end
    response_with user, {guid: user.guid, password_digest: user.password_digest}
  end

  # update the user
  put :update, map: '/api/v1/users/:guid' do
    user = User.find_in_db(params[:guid])
    if user && user.update_attributes(JSON.parse(params[:user]))
      user.delete_from_cache
      user.put_in_cache
    end
    response_with user
  end

  # confirm user who has requested hash, refresh user in cache
  get :confirmation, map: '/api/v1/confirmation/:hashs' do
    user = User.where(hashs: params[:hashs])
    if user.count == 1
      user = user.first
      user.confirmed = true
      user.hashs = nil
      if user.save
        user.delete_from_cache
        user.put_in_cache
      end
    end
    response_with user
  end

  # delete user from DB and cache
  delete :destroy, map: '/api/v1/users/' do
    user = User.find_in_db(params[:guid])

    if user
      user.delete_from_cache
      user.destroy
      response_with user, 'The User can not be deleted!'
    end
  end

  # get all data for the exact user
  get :full_db, map: '/api/v1/users/:guid/full_db' do
    response = User.find_in_db(params[:guid]).get_all_data
  end

  private

    def restrict_access
      api_key = ApiKey.get(params[:access_token])
      head :unauthorized unless api_key
    end
end
