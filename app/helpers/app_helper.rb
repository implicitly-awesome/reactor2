Reactor2::App.helpers do

  # send response with some model
  def response_with(model, data = 'ok')
    if model.errors.none?
      response = data.to_json
    else
      response = model.errors.messages.map {|k,v| "#{k}: #{v}"}
    end
  end
end
