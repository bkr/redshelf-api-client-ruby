# redshelf-api-client-ruby

Facilitates connection and requests to the Redshelf API.

## Setup

```ruby
require 'redshelf-api-client-ruby'

RedshelfApiClient.configure(:username => '{username}', :pem_file => '{path_to_private_key}')
```

## Requests
RedshelfApiClient instances support the following methods which make HTTP requests to the Redshelf API. They return response objects built from the JSON response, with method-like accessors.

### General response methods
Every request method documented below returns an object that responds to a few general-purpose methods:

```ruby
root = RedshelfApiClient.new.index
root.code
# => 200
root.success?
# => true
puts root.body
{
    "api": {
        "admin": "terry@virdocs.com",
        "available_versions": [
            {
                "version": "v1",
                "version_date": "2015-01-21",
                "version_help": "/v1/describe/",
                "version_major": 1,
                "version_string": "1.0.3",
                "version_url": "/v1/"
            }
        ],
        "current_version": "v1",
        "host": "planck.redshelf.com",
        "vhost": "api.redshelf.com"
    },
    "code": 200,
    "success": true,
    "test_mode": false
} 
```

### Error responses
In the case when the response object returns *false* for ".success?" the accessors will reflect the error response instead of the typical successful response.

```
book = RedshelfApiClient.new.book(:isbn => 'BAD')
book.success?
# => false
book.code
# => 404
book.message
# => "Book not found"
book.author
# NoMethodError: undefined method `author' for #<RedshelfApiClient::ResponseClasses::Book:0x007f9fb7582678>
```

### Index
Return the API index which includes general information about the current status of the service.

```ruby
response = RedshelfApiClient.new.index
# => {"api"=>{"admin"=>"terry@virdocs.com", "available_versions"=>[{"version"=>"v1", "version_date"=>"2015-01-21", "version_help"=>"/v1/describe/", "version_major"=>1, "version_string"=>"1.0.3", "version_url"=>"/v1/"}], "current_version"=>"v1", "host"=>"volta.redshelf.com", "vhost"=>"api.redshelf.com"}, "code"=>200, "success"=>true, "test_mode"=>false}
response.api.admin
# => "terry@virdocs.com"
```

### Profile
Return information about your account including access constraints.

```ruby
RedshelfApiClient.new.profile
# =>  => {"code"=>200, "profile"=>{"address_1"=>nil, "address_2"=>nil, "city"=>nil, "country"=>nil, "nickname"=>nil, "state"=>nil, "zip"=>nil}, "scopes"=>"[\"users\", \"invite_user\", \"create_user\", \"create_orders\", \"refunds\", \"bdp\", \"import\"]", "success"=>true, "test_mode"=>false, "username"=>"{username}"}
```

### Book (Version 1)
Returns information about a specific book. Accepts :hash_id, :isbn, or :sku attributes.

```ruby
RedshelfApiClient.new.book(:isbn => '9780321558237')
#  => {"author"=>"Lisa A. Urry, Steven A. Wasserman, Jane B. Reece, Peter V. Minorsky, Michael L. Cain, Robert B. Jackson", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
```

### Book Search (Version 1)
Search for books matching the specified attributes. Supported attributes are :isbn (a list of isbns), :title, and :author.
Supply a block to iterate through the books. If there is an error response, the error will be yielded to the block.
```ruby
RedshelfApiClient.new.book_search(:isbn => ['9780321558237', '9780321974730']) {|book| puts book.author }
# Lisa A. Urry, Steven A. Wasserman, Jane B. Reece, Peter V. Minorsky, Michael L. Cain, Robert B. Jackson
# Lisa A. Urry, Steven A. Wasserman, Jane B. Reece, Peter V. Minorsky, Michael L. Cain, Robert B. Jackson
```

### Book Index (Version 1)
Obtain a list of books controlled by the current account. Supply a block to iterate through the books. If there is an error response, the error will be yielded to the block.

```ruby
RedshelfApiClient.new.book_index{|book| puts book.author }
```

### Book Viewer (Version 1)
Get a URL to the reader for a given user and book.

```ruby
RedshelfApiClient.new.book_viewer(username, book_hash_id)
# => {"code"=>200, "success"=>true, "test_mode"=>true, "viewer_url"=>"https://platform.virdocs.com/viewer/..."}
# or
# => {"username"=>"9d4c827795ac03f45f7af8f24bf568", "code"=>404, "test_mode"=>false, "error"=>true, "message"=>"Purchase for user not found.", "hash_id"=>"8db0cf64ee1ed2069d4c0884ce8c697ca2eb0893"}
```
  
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
  
  def order_free(username, book_hash_id, attributes)
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
  
  def code_generation(attributes)
    builder.v1.codes.generate.post(
      :hash_id => attributes[:hash_id],
      :count => attributes[:count],
      :org => attributes[:org],
      :limit_days => attributes[:limit_days],
      :expiration_date => normalize_date(attributes[:expiration_date]),
      :samples => attributes[:samples] ? 'true' : 'false', #FIXME???
      :label => attributes[:label]
    )
  end
  
  def code_summary


## Copyright

Copyright (c) 2015 Rafter™ Inc. See LICENSE.txt for further details.

