Reactor2::App.helpers do
  # send response with some object
  def response_with(obj, out = '')
    if obj.errors.none?
      message = {"SCCS"=>out}
      success_resp message.to_json
    else
      errors = {}
      errors['ERRS'] = obj.errors.messages.map {|k,v| "#{k}: #{v}"}
      error_resp obj, errors.to_json
    end
  end

  def error_resp(obj, message=nil)
    status 400
    if request.xhr?
      content_type 'application/json'
      @resp[:success] = false
      @resp[:common]  = obj.errors if message == nil
      @resp[:message] = message if message
      halt 400, @resp.to_json
    else
      flash[:warning] = obj.errors.full_messages if message == nil
      flash[:warning] = message if message
    end
  end

  def success_resp(message)
    if request.xhr?
      content_type 'application/json'
      @resp[:success] = true
      @resp[:message] = message
      halt 200, @resp.to_json
    else
      flash[:notice] = message
    end
  end
end
