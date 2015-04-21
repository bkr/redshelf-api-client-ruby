module RestBuilder::JsonContent
  
  def setup_request(request)
    if request.body
      request.body = request.body.to_json 
      request.headers['Content-Type'] = 'application/json'
    end
    
    super(request)
  end
  
end