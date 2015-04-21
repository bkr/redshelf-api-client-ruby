module RestBuilder
  class ResponseError < RestBuilder::Error
    attr_reader :request, :response
    
    def initialize(request, response)
      @request = request
      @response = response
      super("#{request.verb} #{request.url} responded with #{response.code}")
    end
  end
end