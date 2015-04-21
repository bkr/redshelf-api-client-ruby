module RestBuilder
  class ConnectionError < RestBuilder::Error
    attr_reader :request
    
    def initialize(request, root_error)
      @request = request
      @root_error = root_error
      super("Could not connect to #{request.verb} #{request.url}: #{@root_error.message}")
    end
    
    def backtrace
      @root_error.backtrace
    end
  end
end