module RestBuilder

  class Request
    attr_accessor :verb, :url, :headers, :body

    def initialize(verb, url, body=nil)
      @verb = verb
      @url = url
      @body = body
      @headers = {}
    end
  end

end