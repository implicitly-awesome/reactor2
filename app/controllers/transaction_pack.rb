Reactor2::App.controllers :transaction_pack do
  before {content_type :json}
  before :show, :actual, :last do
    @transaction_pack = TransactionPack.get(params[:user_guid])
  end

  get :index, map: '/api/v1/transaction_packs' do
    @transaction_packs = TransactionPack.all
    render 'transaction_pack/index'
  end

  get :show, map: '/api/v1/transaction_packs/:user_guid' do
    render 'transaction_pack/show'
  end

  # give last user transaction
  get :last, map: '/api/v1/transaction_packs/:user_guid/last/' do
    response = get_last_transaction_id(@transaction_pack).to_json
  end

  # give only actual transactions (id > :guid_on_devise)
  get :actual, map: '/api/v1/transaction_packs/:user_guid/last/:guid_on_devise' do
    @transactions = []
    @transaction_pack.transactions.each do |t|
      @transactions.push(t) if t.guid.to_i > params[:guid_on_devise].to_i
    end
    render 'transaction/index'
  end

  post :create, map: '/api/v1/transaction_packs' do
    transaction_pack = TransactionPack.new
    transaction_pack.guid = ModelsExtensions::Extensions.get_guid
    transaction_pack.user = User.find_in_db(params[:user_guid])
    transaction_pack.put_in_cache if transaction_pack.save
    response_with transaction_pack
  end

  put :update, map: '/api/v1/transaction_packs/:user_guid' do
    transaction_pack = TransactionPack.get(params[:user_guid])

    unless transaction_pack
      transaction_pack = TransactionPack.new
      transaction_pack.guid = ModelsExtensions::Extensions.get_guid
      transaction_pack.user = User.find_in_db(params[:user_guid])
      transaction_pack.put_in_cache if transaction_pack.save
    end

    # new TransactionPack as storage for sync_pack's transactions
    #transactions = TransactionPack.new(JSON.parse(params[:transaction_pack].to_s)).sync_pack
    transactions = JSON.parse(params[:sync_pack])

    transactions.each do |t|
      transaction = Transaction.new(t)
      transaction.guid = ModelsExtensions::Extensions.get_guid
      transaction.user = User.find_in_db(params[:user_guid])
      transaction.transaction_pack = transaction_pack
      transaction.save
      transaction_pack.add_transaction transaction
    end

    transaction_pack.delete_from_cache
    transaction_pack.put_in_cache
    response_with transaction_pack, get_last_transaction_id(TransactionPack.get(params[:user_guid]))
  end

  delete :destroy, map: '/api/v1/transaction_packs/' do
    transaction_pack = TransactionPack.find_in_db(params[:user_guid])

    if transaction_pack
      transaction_pack.delete_from_cache
      transaction_pack.destroy
    end
  end
end
