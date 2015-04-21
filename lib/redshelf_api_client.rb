$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rest_builder'
require 'time'

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
  
  ### start API METHODS ###
  
  def index
    builder.get
  end
  
  def profile
    builder.profile.get
  end
  
  def book(attributes)
    response_content(
      if attributes[:hash_id]
        builder.v1.book(attributes[:hash_id]).get
      elsif attributes[:isbn]
        builder.v1.book("isbn/#{attributes[:isbn]}").get
      elsif attrubutes[:sku]
        builder.v1.book("sku/#{attributes[:sku]}").get
      else
        raise ArgumentError.new("Expected attributes to contain :hash_id, :isbn, or :sky")
      end,
      :book
    )
  end
  
  def book_search(attributes, &block)
    search = {:isbn => Array(attributes[:isbn]), :title => attributes[:title], :author => attributes[:author]}
    iterate(block) do |limit, offset|
      response_content(
        builder.v1.book("search").post(search.merge(:limit => limit, :offset => offset)),
        :results
      )
    end
  end
  
  def book_index(&block)
    iterate(block) do |limit, offset|
      response = 
      response_content(
        builder.v1.book.index.get(:limit => limit, :offset => offset),
        :results
      )
    end
  end
  
  def book_viewer(username, book_hash_id)
    builder.v1.book.viewer.post(:username => username, :hash_id => book_hash_id)
  end
  
  def invite_user(attributes)
    builder.v1.user.invite.post(
      :email => attributes[:email], 
      :first_name => attributes[:first_name],
      :last_name => attributes[:last_name],
      :profile => attributes[:profile],
      :label => attributes[:label]
    )
  end
  
  def create_user(attributes)
    builder.v1.user.post(
      :email => attributes[:email], 
      :first_name => attributes[:first_name],
      :last_name => attributes[:last_name],
      :passwd => attributes[:password],
      :passwd_confirm => attributes[:password_confirmation],
      :profile => attributes[:profile],
      :label => attributes[:label],
    )
  end
  
  def user(attributes)
    response_content(
      if attributes[:username]
        builder.v1.user(attributes[:username]).get
      elsif attributes[:email]
        builder.v1.user.email(attributes[:email]).get
      else
        raise ArgumentError.new("Expecting attributes to contain :username or :email.")
      end,
      :user
    )
  end
  
  def user_orders(username)
    response_content(
      builder.v1.user(username).orders.get,
      :results 
    )
  end
  
  def create_order(attributes)
    builder.v1.order.external.post(
      :username => attributes[:username], 
      :digital_pricing => attributes[:digital_pricing] || [], 
      :print_pricing => attributes[:print_pricing] || [], 
      :combo_pricing => attributes[:combo_pricing] || [],
      :billing_address => normalize_address(attributes[:billing_address]),
      :shipping_address => normalize_address(attributes[:shipping_address]),
      :send_email => attributes[:send_email] ? 'true' : 'false', # FIXME???
      :org => attributes[:org],
      :label => attributes[:label]
    )
  end
  
  def order_refund(id, items = [], type = 'refund')
    builder.v1.order.refund(:order_id => id, :items => items, :type => refund_type)
  end
  
  def order_free(username, book_hash_id, attributes = {})
    builder.v1.order.free.post(
      :username => username, 
      :hash_id => book_hash_id, 
      :expiration_date => normalize_date(attributes[:expiration_date]),
      :label => attributes[:label]
    )
  end
  
  def order_usage(id)
    builder.v1.order(id).usage.get
  end
  
  def code_generation(hash_id, count, attributes = {})
    builder.v1.codes.generate.post(
      :hash_id => hash_id,
      :count => count.to_i,
      :org => attributes[:org],
      :limit_days => attributes[:limit_days],
      :expiration_date => normalize_date(attributes[:expiration_date]),
      :samples => attributes[:samples] ? 'true' : 'false', #FIXME???
      :label => attributes[:label]
    )
  end
  
  def code_summary
    builder.v1.codes.summary.get
  end
  
  ### END API METHODS ###
  
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
  
  def normalize_address(address)
    address.nil? ? {} : address
  end
  
  def normalize_date(date)
    return nil if date.nil? || date.blank?
    Time.parse(date.to_s).strftime("%F %T") #FIXME???
  end

end

require 'redshelf_api_client/methodized_hash'
require 'redshelf_api_client/builder'

