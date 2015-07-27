class RedshelfApiClient
  
  module Requests
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
          raise ArgumentError.new("Expected attributes to contain :hash_id, :isbn, or :sku")
        end,
        :book
      )
    end
  
    def book_search(attributes, &block)
      raise ArgumentError.new("Must supply a block (e.g. RedshelfApiClient.new.book_search(attributes){|book| ... })") unless block_given?
      search = {:isbn => Array(attributes[:isbn]), :title => attributes[:title], :author => attributes[:author]}
      iterate(block) do |limit, offset|
        response_content(
          builder.v1.book("search").post(search.merge(:limit => limit, :offset => offset)),
          :results
        )
      end
    end
  
    def book_index(&block)
      raise ArgumentError.new("Must supply a block (e.g. RedshelfApiClient.new.book_index {|book| ... })") unless block_given?
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
      builder.v1.user("invite").post(
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
          builder.v1.user("email/#{attributes[:email]}").get
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
      response_content(
        builder.v1.order("external").post(
          :username => attributes[:username],
          :digital_pricing => Array(attributes[:digital_pricing]) || [], 
          :print_pricing => Array(attributes[:print_pricing]) || [], 
          :combo_pricing => Array(attributes[:combo_pricing]) || [],
          :billing_address => normalize_address(attributes[:billing_address]),
          :shipping_address => normalize_address(attributes[:shipping_address]),
          :send_email => attributes[:send_email] ? 'true' : 'false', # FIXME???
          :order_type => attributes[:order_type] || '',
          :org => attributes[:org] || '',
          :label => attributes[:label],
          :order_number => attributes[:order_number] || ''
        ),
        :order
      )
    end
  
    def order_refund(id, items = [], type = 'refund')
      builder.v1.order.refund.post(:order_id => id, :items => items, :type => type)
    end
  
    def order_free(username, book_hash_id, attributes = {})
      builder.v1.order("free").post(
        :username => username, 
        :hash_id => book_hash_id, 
        :expiration_date => normalize_date(attributes[:expiration_date]),
        :label => attributes[:label]
      )
    end
    
    def allow_access(username, book_hash_id, provider_external_price_cents)
      builder.v1.access("allow").post(
        :hash_id => book_hash_id,
        :username => username,
        :price => normalize_price(provider_external_price_cents)
      )
    end
    
    def revoke_access(username, book_hash_id)
      builder.v1.access("revoke").post(
        :hash_id => book_hash_id,
        :username => username
      )
    end
  
    def order_usage(id)
      builder.v1.order(id).usage.get
    end
  
    def code_generation(hash_id, count, attributes = {})
      builder.v1.codes("generate").post(
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
      builder.v1.codes("summary").get
    end
    
    def catalogue(date)
      builder.v1.catalogue.post(
      :date => date
      )
    end
    
    def catalogue_delta(datetime)
      adjusted_datetime = Time.parse(datetime.to_s).
        in_time_zone("Eastern Time (US & Canada)").
        strftime("%Y-%m-%d %H:%M")
        
      builder.v1.catalogue("delta").post(
        :start_datetime => adjusted_datetime
      )
    end
      
  end
  
  include Requests
end
