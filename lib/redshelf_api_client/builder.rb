require 'active_model'

class RedshelfApiClient
  class Builder < RestBuilder::RestClient
    
    def url
      out = [domain, url_components].flatten.compact.join("/") + '/' + params_to_string
      out
    end
    
    def params_to_string
      return '' if params.nil? || params == ''
      return "?#{params.to_s}" unless params.is_a?(Hash)
      return '' if params.empty?
      as_string = ->(key, val) {
        if val.is_a?(Array)
          return val.map{|vv| as_string[key.to_s + '[]', vv] }.join('&')
        elsif val.is_a?(Hash)
          return val.map{|kk,vv| as_string[key.to_s + "[#{kk}]", vv] }.join('&')
        else
          return "#{key}=#{val}"
        end
      }
      params.map {|key, val| as_string[key, val] }.join('&')
    end
    
    def setup_request(request)
      headers['Accept'] = 'application/json'
      headers['USER'] = username
      headers['API_USER'] = username
      headers['SIGNATURE'] = signature(request)
      
      headers.each { |k, v| request.headers[k] = v }
      request.body = request_body(request)
      request.url = "#{request.url}/"
      request
    end
    
    def signature(request)
      Base64.encode64( OpenSSL::PKey::RSA.new(rsakey).sign(OpenSSL::Digest::SHA256.new, request_json(request)) ).gsub(/\s/,'')
    end
    
    def request_json(request)
      request.body.nil? ? username : request.body.to_json
    end
  
    def request_body(request)
      request.body.nil? ? nil : "request=#{CGI.escape(request_json(request))}"
    end
    
    def rsakey
      @rsakey ||= File.read(RedshelfApiClient.config[:pem_file])
    end
    
    def username
      RedshelfApiClient.config[:username]
    end
    
    def call(request)
      response = super(request)
      class_name = url_components.last.try(:class_name) || 'Root'

      response_class = if ResponseClasses.const_defined?(class_name, false)
        ResponseClasses.const_get(class_name)
      else
        ResponseClasses.const_set(class_name, Class.new(BuilderResponse))
      end

      response_class.from_response(response)
    end
  end
  
  class BuilderResponse < MethodizedHash
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    attr_accessor :response, :class_name
    delegate :success?, :code, :headers, :body, to: :response
    
    def self.from_response(response)
      json = JSON.parse(response.body) rescue {}
      
      if json.is_a?(Array)
        BuilderListResponse.new(json.map {|attrs| self.from(attrs) }, response)
      else
        self.from(json).tap {|br| br.response = response }
      end
    end
    
    def self.from(maybe_hash)
      if maybe_hash.is_a?(Array)
        BuilderListResponse.new(super, nil)
      else
        super
      end
    end
    
    def persisted?
      false
    end
  end
  
  class BuilderListResponse < Array
    attr_accessor :response
    delegate :success?, :code, :headers, :body, to: :response
    
    def initialize(array, response)
      @response = response
      super(array)
    end
    
    def success?
      response.success?
    end
  end
  
  module ResponseClasses
    def self.use_relative_model_naming?
      true
    end    
  end
end