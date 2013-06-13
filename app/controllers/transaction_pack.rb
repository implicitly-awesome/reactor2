Reactor2::App.controllers :transaction_pack do
  before {content_type :json}

  before do
    unless has_access? params[:user_guid], params[:token]
      @message = ApiMessage.new('Access denied', :error)
    end
  end

  # Get the list of transaction packs
  get :index, map: '/api/v1/transaction_packs' do
    #if @message
    #  render 'common/message'
    #else
      @transaction_packs = TransactionPack.all
      render 'transaction_pack/index'
    #end
  end

  # Get exact transaction pack
  get :show, map: '/api/v1/transaction_packs/:user_guid' do
    @transaction_pack = TransactionPack.get(params[:user_guid])
    render 'transaction_pack/show'
  end

  # Give last user transaction
  get :last, map: '/api/v1/transaction_packs/:user_guid/last/' do
    @transaction_pack = TransactionPack.get(params[:user_guid])
    response = get_last_transaction(@transaction_pack)
  end

  # Give only actual transactions (id > :guid_on_devise)
  get :actual, map: '/api/v1/transaction_packs/:user_guid/last/:guid_on_devise' do
    @transaction_pack = TransactionPack.get(params[:user_guid])
    @transactions = []
    if @transaction_pack && @transaction_pack.transactions
      @transaction_pack.transactions.each do |t|
        @transactions.push(t) if t.guid.to_i > params[:guid_on_devise].to_i
      end
    else
      nil
    end
    render 'transaction/index'
  end

  # DEPRECATED - use Update method
  post :create, map: '/api/v1/transaction_packs' do
    #transaction_pack = TransactionPack.new
    #transaction_pack.guid = ModelsExtensions::Extensions.get_guid
    #transaction_pack.user = User.find_in_db(params[:user_guid])
    #transaction_pack.put_in_cache if transaction_pack.save
    #response_with transaction_pack
    @message ||= 'Deprecated'
    render 'common/message'
  end

  # Update a transaction pack if it exists, if not - create it
  put :update, map: '/api/v1/transaction_packs/:user_guid' do
    # try get transaction pack from cache or from the DB
    transaction_pack = TransactionPack.create_from_json(TransactionPack.find_in_cache(params[:user_guid])) ||
        TransactionPack.find_in_db(params[:user_guid])

    # Create new transaction pack because it's not exists
    unless transaction_pack
      transaction_pack = TransactionPack.new
      transaction_pack.guid = params[:user_guid] if User.get(params[:user_guid])
      transaction_pack.put_in_cache if transaction_pack.save
    end

    # New transaction pack as storage for sync_pack's transactions
    transactions = JSON.parse(params[:sync_pack])

    # For each hash in sync pack create transaction then append that to the transaction pack
    transactions.each do |t|
      transaction = Transaction.new(t)
      transaction.guid = ModelsExtensions::Extensions.get_guid
      transaction.user_guid = params[:user_guid] if User.get(params[:user_guid])
      transaction_pack.transactions.push transaction
    end

    # Refresh transaction pack in cache
    transaction_pack.delete_from_cache
    transaction_pack.put_in_cache

    # Send response with object status and additional message
    response_with transaction_pack, get_last_transaction_id(transaction_pack)
  end

  # Delete transaction pack from DB and cache
  delete :destroy, map: '/api/v1/transaction_packs/' do
    transaction_pack = TransactionPack.find_in_db(params[:user_guid])

    if transaction_pack
      transaction_pack.delete_from_cache
      transaction_pack.destroy
    end
  end

  # Get transactions list embedded in transaction pack
  get :transactions_index, map: '/api/v1/transaction_packs/:user_guid/transactions/' do
    @transaction_pack = TransactionPack.get(params[:user_guid])
    @transactions = @transaction_pack.transactions if @transaction_pack && @transaction_pack.transactions
    render 'transaction/index'
  end

  # Get exact transaction from the list of embedded in transaction pack
  get :transactions_show, map: '/api/v1/transaction_packs/:user_guid/transactions/:guid' do
    @transaction_pack = TransactionPack.get(params[:user_guid])
    @transaction = @transaction_pack.transactions.where(guid: params[:guid]).first if @transaction_pack && @transaction_pack.transactions
    render 'transaction/show'
  end
end
