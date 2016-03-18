# RestBuilder.schools  # => /schools
# RestBuilder.schools(1, search: 'scu') # => /schools/1?search=scu
# RestBuilder.schools(1, search: 'scu').courses # => /schools/1?search=scu/courses
# RestBuilder.schools(1).courses(search: 'scu') # => /schools/1/courses?search=scu
require 'active_support/all'
require 'rest_builder/url_component'
require 'rest_builder/request'
require 'rest_builder/response'
require 'rest_builder/error'

module RestBuilder
  class Builder
    instance_methods.reject { |m| m =~ /(^__)|(\?$)/ || [:inspect, :to_s, :object_id, :send, :tap, :class].include?(m) }.each { |m| undef_method m }
    
    class << self
      def method_missing(*args, &block)
        new.send(*args)
      end
    end

    attr_accessor :url_components, :headers
    attr_reader :verb, :domain, :raw_params, :request, :response

    def initialize(domain=nil)
      @url_components = []
      @domain = domain
      @headers = {}
    end
    
    def dup
      out = self.class.new(@domain)
      out.url_components = @url_components.dup
      out
    end

    def method_missing(name, *args, &block)
      out = dup
      out.url_components << UrlComponent.new(name, *args)
      out
    end
  
    def url
      out = [domain, url_components].flatten.compact.join("/")
      out += "?#{params.to_query}" unless params.blank?
      out
    end
      
    def body
      params_in_url? ? {} : raw_params
    end
  
    def params
      params_in_url? ? raw_params : {}
    end

    # def get(raw_params={})
    #   @verb = verb
    #   @raw_params = raw_params
    #   
    #   @request = if params_in_url?
    #     Request.new(verb, url)
    #   else
    #     Request.new(verb, url, body)
    #   end
    #   
    #   @response = call!(@request)
    # end
    %w[get post put delete].each do |verb|      
      verb_request_method_definition = ->(raw_params={}) do
        @verb = verb

        if bulk_allowed?
          raise ArgumentError.new("Expecting Hash or Array of Hashes, got: #{raw_params.inspect}") unless raw_params.is_a?(Hash) || (raw_params.is_a?(Array) && raw_params.all?{|p| p.is_a?(Hash)})
        else
          raise ArgumentError.new("Expecting Hash, got: #{raw_params.inspect}") unless raw_params.is_a?(Hash)
        end
        @raw_params = raw_params
    
        @request = if params_in_url?
          Request.new(verb, url)
        else
          Request.new(verb, url, body)
        end
        setup_request(@request)
        @request
      end
      define_method("#{verb}_request", verb_request_method_definition)
      
      verb_method_definition = ->(raw_params={}) do
        @response = call(send("#{verb}_request", raw_params))
      end
      define_method(verb, verb_method_definition)      
      
      verb_bang_method_definition = ->(raw_params={}) do
        @response = call!(send("#{verb}_request", raw_params))
      end            
      define_method("#{verb}!", verb_bang_method_definition)
    end

    alias_method :show, :get
    alias_method :all, :get
    alias_method :create, :post
    alias_method :update, :put
    alias_method :destroy, :delete
    
    alias_method :show!, :get!
    alias_method :all!, :get!
    alias_method :create!, :post!
    alias_method :update!, :put!
    alias_method :destroy!, :delete!
    
    alias_method :show_request, :get_request
    alias_method :all_request, :get_request
    alias_method :create_request, :post_request
    alias_method :update_request, :put_request
    alias_method :destroy_request, :delete_request 
    
    def setup_request(request)
      headers.each { |k, v| request.headers[k] = v }
      request
    end
    
    def call(request)
      Response.new(200, '', "#{request.verb} #{request.url} #{request.body.inspect}")
    end    
    
    def call!(request)
      response = call(request)
      raise RestBuilder::ResponseError.new(request, response) unless response.success?
      response
    end
  
    private
  
    def params_in_url?
      %w[get delete].include?(verb)
    end

    def bulk_allowed?
      %w[post].include?(verb)
    end
  end
  
end