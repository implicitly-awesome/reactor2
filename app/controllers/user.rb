Reactor2::App.controllers :user do
  before {content_type :json}
  before :show do
    @user = get_user(params[:id])
  end

  get :index, map: '/api/v1/users' do
    @users = User.all
    render 'user/index'
  end

  get :show, map: '/api/v1/users/:id' do
    render 'user/show'
  end

  post :create, map: '/api/v1/users' do
    user = User.new(JSON.parse(params[:user].to_s))
    user.save
    response_with user
  end

  put :update, map: '/api/v1/users/:id' do
    user = get_user(params[:id])
    if user && user.update_attributes(JSON.parse(params[:user].to_s))
      user.delete_from_cache
      user.put_in_cache
    end
    response_with user
  end

  delete :destroy, map: '/api/v1/users/:id' do
    user = User.find_in_db(params[:id])

    if user
      user.delete_from_cache
      user.destroy
    end
  end
end
