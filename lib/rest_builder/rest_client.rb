require 'rest_client'
require 'rest_builder/builder'

module RestBuilder
  
  class RestClient < Builder
    
    def call(request)
      begin
        in_production = !!((Rails rescue nil) and Rails.env == 'production')
        response = nil
        rest_client = ::RestClient::Request.new(
            :method => request.verb,
            :url => request.url,
            :payload => request.body.to_s,
            :headers => request.headers,
            :verify_ssl => in_production ? OpenSSL::SSL::VERIFY_PEER : OpenSSL::SSL::VERIFY_NONE)
        rest_client.execute do |rc_response|
          response = rc_response
        end
      rescue StandardError => e # Note: RestClient can raise SocketError which is not a RuntimeError
        raise RestBuilder::ConnectionError.new(request, e)
      end
      Response.new(response.code, response.headers, response.body)
    end
  end
  
end