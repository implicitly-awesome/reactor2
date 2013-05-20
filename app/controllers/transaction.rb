Reactor2::App.controllers :transaction do

  get :index, map: '/api/v1/transactions' do
    @transactions = Transaction.all
    render 'transaction/index'
  end

  get :show, map: '/api/v1/transactions/:id' do
    begin
      @transaction = Transaction.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      @transaction = {}
    end
    render 'transaction/show'
  end

  post :create, map: '/api/v1/transactions' do
    content_type :json

    transaction = Transaction.new(JSON.parse(params[:transaction].to_s))
    transaction.save
    response_with transaction
  end

  put :update, map: '/api/v1/transactions/:id' do
    content_type :json

    begin
      transaction = Transaction.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      transaction = nil
    end

    transaction.update_attributes(JSON.parse(params[:transaction].to_s)) if transaction && transaction.valid?
  end

  delete :destroy, map: '/api/v1/transactions/:id' do
    content_type :json

    begin
      transaction = Transaction.find(params[:id])
    rescue Mongoid::Errors::DocumentNotFound
      transaction = nil
    end

    transaction.destroy if transaction
  end
end