Reactor2::App.controllers :transaction do
  before {content_type :json}
  before :show do
    @transaction = get_transaction(params[:id])
  end

  get :index, map: '/api/v1/transactions' do
    @transactions = Transaction.all
    render 'transaction/index'
  end

  get :show, map: '/api/v1/transactions/:id' do
    render 'transaction/show'
  end

  post :create, map: '/api/v1/transactions' do
    transaction = Transaction.new(JSON.parse(params[:transaction].to_s))
    transaction.save
    response_with transaction
  end

  put :update, map: '/api/v1/transactions/:id' do
    transaction = get_transaction(params[:id])
    if transaction && transaction.update_attributes(JSON.parse(params[:transaction].to_s))
      transaction.delete_from_cache
      transaction.put_in_cache
    end
    response_with transaction
  end

  delete :destroy, map: '/api/v1/transactions/:id' do
    transaction = Transaction.find_in_db(params[:id])

    if transaction
      transaction.delete_from_cache
      transaction.destroy
    end
  end
end