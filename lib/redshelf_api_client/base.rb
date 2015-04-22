require 'rest_builder'

class RedshelfApiClient

  DEFAULT_CONFIG = {:site => 'https://api.redshelf.com', :request_per_page => 500}

  cattr_accessor :config
  attr_accessor :config
  
  def self.configure(config)
    @@config = DEFAULT_CONFIG.dup.merge(config)
    @@config[:request_per_page] = @@config[:request_per_page].to_i
    raise ArgumentError.new(":request_per_page must be greater than 1!") if  @@config[:request_per_page] < 2
    @@config
  end
  
  def initialize(config = RedshelfApiClient.config)
    @config = config
  end
  
  def builder
    RedshelfApiClient::Builder.new(config[:site])
  end
  
  private
  
  def response_content(response, key)
    if response[key]
      response.send(key).tap{|res| res.response = response.response }
    else
      response
    end
  end
  
  def iterate(response_proc, &block)
    offset = 0
    limit = RedshelfApiClient.config[:request_per_page].to_i
    results = []
    begin
      retries = 0
      begin
        results = block.call(limit, offset)
      rescue StandardError => se
        if (retries+=1) > 4
          retry
        else
          raise se
        end
      end
      
      results.each{|result| response_proc.call(result) }
      offset += limit
    end while results.size == limit
    
  end

end