Reactor2::App.controllers :transaction_pack do
  before {content_type :json}
  before :show, :actual, :last do
    @transaction_pack = get_transaction_pack(params[:user_guid])
  end

  get :test, map: '/api/v1/test' do
   response = [{tweet:"Hella World!"},{tweet:"New Rails has been released"}].to_json
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

  # give only actual transactions (id > :guid_on_devise), in cache and DB leave all transactions
  get :actual, map: '/api/v1/transaction_packs/:user_guid/last/:guid_on_devise' do
    transactions = @transaction_pack.transactions
    transactions.each do |t|
      @transaction_pack.transactions.delete(t) if t._id.to_i <= params[:guid_on_devise].to_i
    end
    render 'transaction_pack/show'
  end

  post :create, map: '/api/v1/transaction_packs' do
    response_with create_transaction_pack(params[:user_guid])
  end

  put :update, map: '/api/v1/transaction_packs/:user_guid' do
    transaction_pack = get_transaction_pack(params[:user_guid])

    unless transaction_pack
      transaction_pack = create_transaction_pack(params[:user_guid])
    end

    # new TransactionPack as storage for sync_pack's transactions
    transactions = TransactionPack.new(JSON.parse(params[:transaction_pack].to_s)).sync_pack

    transactions.each do |t|
      transaction = Transaction.new(t)
      transaction.user = User.find_in_db(params[:user_guid])
      transaction.transaction_pack = transaction_pack
      transaction.save
      transaction_pack.transactions << transaction
    end

    transaction_pack.delete_from_cache
    transaction_pack.put_in_cache
    response_with transaction_pack, get_last_transaction_id(get_transaction_pack(params[:user_guid]))
  end

  delete :destroy, map: '/api/v1/transaction_packs/:user_guid' do
    transaction_pack = TransactionPack.find_in_db(params[:user_guid])

    if transaction_pack
      transaction_pack.delete_from_cache
      transaction_pack.destroy
    end
  end
end
