Reactor2::App.controllers :transaction_pack do
  before {content_type :json}
  before :restrict_access
  before :show, :actual, :last, :transactions_index, :transactions_show do
    @transaction_pack = TransactionPack.get(params[:user_guid])
  end

  # get the list of transaction packs
  get :index, map: '/api/v1/transaction_packs' do
    @transaction_packs = TransactionPack.all
    render 'transaction_pack/index'
  end

  # get exact transaction pack
  get :show, map: '/api/v1/transaction_packs/:user_guid' do
    render 'transaction_pack/show'
  end

  # give last user transaction
  get :last, map: '/api/v1/transaction_packs/:user_guid/last/' do
    response = get_last_transaction(@transaction_pack)
  end

  # give only actual transactions (id > :guid_on_devise)
  get :actual, map: '/api/v1/transaction_packs/:user_guid/last/:guid_on_devise' do
    @transactions = []
    @transaction_pack.transactions.each do |t|
      @transactions.push(t) if t.guid.to_i > params[:guid_on_devise].to_i
    end
    render 'transaction/index'
  end

  # DEPRICATED - use Update method
  post :create, map: '/api/v1/transaction_packs' do
    #transaction_pack = TransactionPack.new
    #transaction_pack.guid = ModelsExtensions::Extensions.get_guid
    #transaction_pack.user = User.find_in_db(params[:user_guid])
    #transaction_pack.put_in_cache if transaction_pack.save
    #response_with transaction_pack
    response = 'Deprecated'
  end

  # update a transaction pack if it exists, if not - create it
  put :update, map: '/api/v1/transaction_packs/:user_guid' do
    # try get transaction pack from cache or from the DB
    transaction_pack = TransactionPack.create_from_json(TransactionPack.find_in_cache(params[:user_guid])) ||
        TransactionPack.find_in_db(params[:user_guid])

    # create new transaction pack because it's not exists
    unless transaction_pack
      transaction_pack = TransactionPack.new
      transaction_pack.user_guid = params[:user_guid] if User.get(params[:user_guid])
      transaction_pack.put_in_cache if transaction_pack.save
    end

    # new transaction pack as storage for sync_pack's transactions
    transactions = JSON.parse(params[:sync_pack])

    # for each hash in sync pack create transaction then append that to the transaction pack
    transactions.each do |t|
      transaction = Transaction.new(t)
      transaction.guid = ModelsExtensions::Extensions.get_guid
      transaction.user_guid = params[:user_guid] if User.get(params[:user_guid])
      transaction_pack.transactions.push transaction
    end

    # refresh transaction pack in cache
    transaction_pack.delete_from_cache
    transaction_pack.put_in_cache

    # send response with object status and additional message
    response_with transaction_pack, get_last_transaction_id(transaction_pack)
  end

  # delete transaction pack from DB and cache
  delete :destroy, map: '/api/v1/transaction_packs/' do
    transaction_pack = TransactionPack.find_in_db(params[:user_guid])

    if transaction_pack
      transaction_pack.delete_from_cache
      transaction_pack.destroy
    end
  end

  # get transactions list embedded in transaction pack
  get :transactions_index, map: '/api/v1/transaction_packs/:user_guid/transactions/' do
    @transactions = @transaction_pack.transactions
    render 'transaction/index'
  end

  # get exact transaction from the list of embedded in transaction pack
  get :transactions_show, map: '/api/v1/transaction_packs/:user_guid/transactions/:guid' do
    @transaction = @transaction_pack.transactions.where(guid: params[:guid]).first
    render 'transaction/show'
  end

  private

    def restrict_access
       api_key = ApiKey.get(params[:access_token])
       head :unauthorized unless api_key
    end
end
