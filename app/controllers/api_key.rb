Reactor2::App.controllers :api_key do

  # Get API Session Key
  post :auth, map: '/api/v1/api_key/auth' do
    # Try to find the user in the DB
    user = User.find_in_db(params[:users_guid])
    # If user exists
    if user && authorize(user, params[:users_pwd])
      # Try to find ApiKey-pair for the user
      key = ApiKey.find_in_db(user.guid)
      # If pair was found
      if key
        # Generates a new token for the user
        key.generate_token
        # Refresh pair in the cache if saving was successful
        if key.save
          key.delete_from_cache
          key.put_in_cache
        end
        # Response with token
        response_with key, key.token
      else
        # Create new ApiKey-pair and response with token
        key = ApiKey.new(guid: user.guid)
        key.guid = ApiKey.get_guid
        key.generate_token
        key.put_in_cache if key.save
        response_with key, key.token
      end
    else
      @message = ApiMessage.new('There is no such user')
      render 'common/message'
    end
  end
end
