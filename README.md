# redshelf-api-client-ruby

Facilitates connection and requests to the Redshelf API.

## Setup

```ruby
require 'redshelf-api-client-ruby'

RedshelfApiClient.configure(:username => '{username}', :pem_file => '/path/to/private_key.pem')
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
# {
#     "api": {
#         "admin": "example@example.com",
#         "available_versions": [
#             {
#                 "version": "v1",
#                 "version_date": "2015-01-21",
#                 "version_help": "/v1/describe/",
#                 "version_major": 1,
#                 "version_string": "1.0.3",
#                 "version_url": "/v1/"
#             }
#         ],
#         "current_version": "v1",
#         "host": "planck.redshelf.com",
#         "vhost": "api.redshelf.com"
#     },
#     "code": 200,
#     "success": true,
#     "test_mode": false
# }
root.headers
# => {:server=>"nginx", :date=>"Tue, 21 Apr 2015 22:10:48 GMT", :content_type=>"application/json", :transfer_encoding=>"chunked", :connection=>"keep-alive"}
```
All response objects have dynamically generated accessors that reflect the data in the JSON response. For convenience, some request methods return data from a child element instead of the full JSON for successful responses.

```ruby
book = RedshelfApiClient.new.book(:isbn => '9780321558237')
book.class
# => RedshelfApiClient::ResponseClasses::Book
book.title
# => "Campbell Biology, 9/e"
book.identifiers.isbn13
#  => "9780321558237"
```

### Error responses
In the case when the response object returns *false* for ".success?" the accessors will reflect the error response instead of the typical successful response.

```ruby
book = RedshelfApiClient.new.book(:isbn => 'BAD')
book.success?
# => false
book.code
# => 404
book.message
# => "Book not found"
book.title
# NoMethodError: undefined method `title' for #<RedshelfApiClient::ResponseClasses::Book:0x007f9fb7582678>
```

### Index
Return the API index which includes general information about the current status of the service.

```ruby
response = RedshelfApiClient.new.index
# => {"api"=>{"admin"=>"example@example.com", "available_versions"=>[{"version"=>"v1", "version_date"=>"2015-01-21", "version_help"=>"/v1/describe/", "version_major"=>1, "version_string"=>"1.0.3", "version_url"=>"/v1/"}], "current_version"=>"v1", "host"=>"volta.redshelf.com", "vhost"=>"api.redshelf.com"}, "code"=>200, "success"=>true, "test_mode"=>false}
response.api.admin
# => "example@example.com"
```

### Profile
Return information about your account including access constraints.

```ruby
RedshelfApiClient.new.profile
# => {"code"=>200, "profile"=>{"address_1"=>nil, "address_2"=>nil, "city"=>nil, "country"=>nil, "nickname"=>nil, "state"=>nil, "zip"=>nil}, "scopes"=>"[\"users\", \"invite_user\", \"create_user\", \"create_orders\", \"refunds\", \"bdp\", \"import\"]", "success"=>true, "test_mode"=>false, "username"=>"{username}"}
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
# => {"username"=>{username}, "code"=>404, "test_mode"=>false, "error"=>true, "message"=>"Purchase for user not found.", "hash_id"=>"8db0cf64ee1ed2069d4c0884ce8c697ca2eb0893"}
```
  
### Invite User (Version 1)
Create a new RedShelf user and send them an invite email with a generated password.

```ruby
RedshelfApiClient.new.invite_user(:email => 'john@example.com', :first_name => 'John', :last_name => 'Doe')
# => {"code"=>200, "email"=>"john@example.com", "message"=>"Invitation sent.", "success"=>true, "test_mode"=>false, "username"=>{username}}
# or
# => {"field"=>"email", "code"=>400, "conflict"=>true, "test_mode"=>false, "error"=>true, "message"=>"User with email address already exists", "value"=>"john@example.com"}
```

### Create User (Version 1)
Create a new RedShelf user silently.  Optional password can be omitted to generate a random password.

```ruby
RedshelfApiClient.new.create_user(:email => 'john@example.com', :first_name => 'John', :last_name => 'Doe', :password => 'abc123', :password_confirmation => 'abc123')
# => {"username"=>{username}, "test_mode"=>false, "code"=>200, "success"=>true, "message"=>"User created.", "email"=>"john@example.com"}
# or
# => {"field"=>"email", "code"=>400, "conflict"=>true, "test_mode"=>false, "error"=>true, "message"=>"User with email address already exists", "value"=>"john@example.com"}
```
  
### User (Version 1)
Request user data by :username or :email

```ruby
RedshelfApiClient.new.user(:username => username)
# => {"username"=>{username}, "status"=>{"last_login"=>"2015-04-21T22:57:19.450Z", "verified"=>false, "is_active"=>true, "over_18"=>true, "date_joined"=>"2015-04-21T22:57:19.451Z"}, "first_name"=>"John", "last_name"=>"Doe", "profile"=>{"city"=>nil, "zip"=>nil, "country"=>nil, "state"=>nil, "address_1"=>nil, "address_2"=>nil, "nickname"=>nil}, "owner"=>{"username"=>{username}, "full_name"=>"Testing"}, "email"=>"john@example.com", "permissions"=>{"html_posting"=>false, "bdp_posting"=>false, "manager"=>false, "billing_admin"=>false, "salesperson"=>false, "developer"=>false}}
RedshelfApiClient.new.user(:email => 'john@example.com')
# => {"username"=>{username}, "status"=>{"last_login"=>"2015-04-21T22:57:19.450Z", "verified"=>false, "is_active"=>true, "over_18"=>true, "date_joined"=>"2015-04-21T22:57:19.451Z"}, "first_name"=>"John", "last_name"=>"Doe", "profile"=>{"city"=>nil, "zip"=>nil, "country"=>nil, "state"=>nil, "address_1"=>nil, "address_2"=>nil, "nickname"=>nil}, "owner"=>{"username"=>{username}, "full_name"=>"Rafter Testing"}, "email"=>"john@example.com", "permissions"=>{"html_posting"=>false, "bdp_posting"=>false, "manager"=>false, "billing_admin"=>false, "salesperson"=>false, "developer"=>false}}
```

### User Orders (Version 1)
Get a list of completed orders for a user.

```ruby
RedshelfApiClient.new.user_orders("15b482122a0f0c015f13d3f87ab2c0")
# => []
# ???
```

### Create Order (External) (Version 1)
```ruby
RedshelfApiClient.new.create_order(:username => username, :digital_pricing => [123], :billing_address => {:first_name => 'John', :last_name => 'Doe', :line_1 => '123 Test St.', :line_2 => 'Apt #42', :city => 'Davis', :state => 'CA', :postal_code => '95616'})
# => {"message"=>"POSPlan is not currently supported.", "code"=>400, "test_mode"=>false, "error"=>true}
# ???
```
  
### Order Refund (Version 1)
Provides a method for reporting refunds processed outside of the RedShelf system. This includes orders where the integration partner is using their own checkout and fund collection processes.

The ID is the order ID returned when an order is created. Optionally a list of item IDs from the order information can be supplied for partial refunds.

```ruby
RedshelfApiClient.new.order_refund(id)
# => ???
RedshelfApiClient.new.order_refund(id, [1,2,3])
# => ???
```

### Order Free (Version 1)
Create an order for free access to a title. Attributes may include optional :expiration_date and :label

```ruby
RedshelfApiClient.new.order_free(username, book_hash_id, :expiration_date => 30.days.from_now)
# => ???
```

### Code Generation (Version 1)

```ruby
RedshelfApiClient.new.code_generation(:hash_id => book_hash_id, :count => 2, :org => 'Testing', :expiration_date => 30.days.from_now, :samples => true)
# => ???
```

### Code Summary (Version 1)

```ruby
RedshelfApiClient.new.code_summary
# => ???
```

## Copyright

Copyright (c) 2015 Rafter™ Inc. See LICENSE.txt for further details.

