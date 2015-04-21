module RestBuilder

  class Response
    attr_accessor :code, :headers, :body

    def initialize(code, headers, body)
      @code, @headers, @body = code, headers, body
    end

    def success?
      code.to_i/100 == 2
    end
  end
  
end