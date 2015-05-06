require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe "RedshelfApiClient" do
  let(:response_headers) { {} }
  let(:response_code) { 200 }
  let(:client) { RedshelfApiClient.new }
  let(:mock_rest_client) { double('rest client') }
  
  context "single requests" do
    let(:response_body) { response_hash.to_json }
    let(:redshelf_response) { OpenStruct.new(:body => response_body, :code => response_code, :headers => response_headers) }
      
    before do
      allow(RestBuilder::RestClient).to receive(:make_request).and_return(redshelf_response)
    end
    
    describe '#index' do
      let(:response_hash) {
        {"api"=>{"admin"=>"terry@virdocs.com", "available_versions"=>[{"version"=>"v1", "version_date"=>"2015-01-21", "version_help"=>"/v1/describe/", "version_major"=>1, "version_string"=>"1.0.3", "version_url"=>"/v1/"}], "current_version"=>"v1", "host"=>"volta.redshelf.com", "vhost"=>"api.redshelf.com"}, "code"=>200, "success"=>true, "test_mode"=>false}
      }
    
      subject { client.index }
    
      it 'returns a root object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Root)
        expect(subject.api.admin).to eq("terry@virdocs.com")
      end
    end
  
    describe '#profile' do
      let(:response_hash) {
        {"code"=>200, "profile"=>{"address_1"=>nil, "address_2"=>nil, "city"=>nil, "country"=>nil, "nickname"=>nil, "state"=>nil, "zip"=>nil}, "scopes"=>"[\"users\", \"invite_user\", \"create_user\", \"create_orders\", \"refunds\", \"bdp\", \"import\"]", "success"=>true, "test_mode"=>false, "username"=>"fake_username"}
      }
    
      subject { client.profile }
    
      it 'returns a profile object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Profile)
        expect(JSON.parse(subject.scopes).first).to eq("users")
      end
    end
  
    describe '#book' do
  
      let(:response_hash) {
        {:book => 
          {"author"=>"Lisa A. Urry, Steven A. Wasserman, Jane B. Reece, Peter V. Minorsky, Michael L. Cain, Robert B. Jackson", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
        }
      }
    
      subject { client.book(request_hash) }
    
      context 'isbn request' do
        let(:request_hash) { {:isbn => '9780321830302'} }
      
        it 'returns a book object' do
          expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Book)
          expect(subject.identifiers.eisbn13).to eq("9780321830302")
        end
      end
    
      context 'isbn request' do
        let(:request_hash) { {:hash_id => 'fb02181f26270f72e261de20f8aadb9096f40802'} }
      
        it 'returns a book object' do
          expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Book)
          expect(subject.identifiers.eisbn13).to eq("9780321830302")
        end
      end
    end
    
    describe '#book_viewer' do
      #TODO
    end
    
    describe '#invite_user' do
      let(:response_hash) {
        {"code"=>200, "email"=>"john@example.com", "message"=>"Invitation sent.", "success"=>true, "test_mode"=>false, "username"=>"fake_username"}
      }
      let(:request_hash) {
        {:email => 'john@example.com', :first_name => 'John', :last_name => 'Doe'}
      }
      
      subject { client.invite_user(request_hash) }
      
      it 'returns a user object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::User)
        expect(subject.username).to eq("fake_username")
      end
    end
    
    describe '#create_user' do
      let(:response_hash) {
        {"username"=>"my_username", "test_mode"=>false, "code"=>200, "success"=>true, "message"=>"User created.", "email"=>"john@example.com"}
      }
      let(:request_hash) {
        {:email => 'john@example.com', :first_name => 'John', :last_name => 'Doe'}
      }
      
      subject { client.invite_user(request_hash) }
      
      it 'returns a user object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::User)
        expect(subject.username).to eq("my_username")
      end
    end
    
    describe '#user' do
      let(:response_hash) {
        {:user =>
          {"username"=>"iamfake", "status"=>{"last_login"=>"2015-04-21T22:57:19.450Z", "verified"=>false, "is_active"=>true, "over_18"=>true, "date_joined"=>"2015-04-21T22:57:19.451Z"}, "first_name"=>"John", "last_name"=>"Doe", "profile"=>{"city"=>nil, "zip"=>nil, "country"=>nil, "state"=>nil, "address_1"=>nil, "address_2"=>nil, "nickname"=>nil}, "owner"=>{"username"=>"rafterfake", "full_name"=>"Testing"}, "email"=>"john@example.com", "permissions"=>{"html_posting"=>false, "bdp_posting"=>false, "manager"=>false, "billing_admin"=>false, "salesperson"=>false, "developer"=>false}}
        }
      }
      
      subject { client.user(request_hash) }
      
      context "with username" do
        let(:request_hash) {
          {:username => 'iamfake'}
        }
        
        it 'returns a user object' do
          expect(subject).to be_a(RedshelfApiClient::ResponseClasses::User)
          expect(subject.username).to eq("iamfake")
        end
      end
      
      context "with email" do
        let(:request_hash) {
          {:email => 'john@example.com'}
        }
        
        it 'returns a user object' do
          expect(subject).to be_a(RedshelfApiClient::ResponseClasses::User)
          expect(subject.username).to eq("iamfake")
        end
      end
    end
    
    describe "#allow_access" do
      let(:response_hash) {
        {
         'code' => 200,
         'success' => true,
         'test_mode' => false
        }
      }
      
      subject { client.allow_access('iamfake', 'fb02181f26270f72e261de20f8aadb9096f40802', 1234) }
      
      it 'returns an access object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Access)
      end
    end
    
    describe "#revoke_access" do
      let(:response_hash) {
        {
         'code' => 200,
         'success' => true,
         'test_mode' => false
        }
      }
      
      subject { client.revoke_access('iamfake', 'fb02181f26270f72e261de20f8aadb9096f40802') }
      
      it 'returns an access object' do
        expect(subject).to be_a(RedshelfApiClient::ResponseClasses::Access)
      end
    
    end
  end
  
  context "multiple requests" do
    let(:response_body1) { response_hash1.to_json }
    let(:redshelf_response1) { OpenStruct.new(:body => response_body1, :code => response_code, :headers => response_headers) }
    let(:response_body2) { response_hash2.to_json }
    let(:redshelf_response2) { OpenStruct.new(:body => response_body2, :code => response_code, :headers => response_headers) }
    let(:yield_output) { [] }
    
    before do
      allow(RestBuilder::RestClient).to receive(:make_request).twice.and_return(redshelf_response1, redshelf_response2)
    end
    
    describe '#book_search' do
      let(:response_hash1) {
        {:results => 
          [{"author"=>"Lisa A. Urry 1", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
          ] * 2
        }
      }

      let(:response_hash2) {
        {:results => 
          [{"author"=>"Lisa A. Urry 2", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
          ] * 1
        }
      }
      
      subject { client.book_search(:author => 'Lisa A. Urry') {|book| yield_output << book } }
    
      it 'makes multiple requests to redshelf and yields the results' do
        subject
        expect(yield_output.size).to eq(3)
        expect(yield_output.map(&:author)).to eq(['Lisa A. Urry 1', 'Lisa A. Urry 1', 'Lisa A. Urry 2'])
      end
    end
    
    describe '#book_index' do
      let(:response_hash1) {
        {:results => 
          [{"author"=>"Lisa A. Urry 1", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
          ] * 2
        }
      }

      let(:response_hash2) {
        {:results => 
          [{"author"=>"Lisa A. Urry 2", "basic_code"=>nil, "bisac_code"=>"", "created_date"=>"2014-09-25T18:19:45.180Z", "description"=>"", "digital_pricing"=>[{"calculated_expiration_date"=>"2015-10-19", "currency"=>"USD", "days_until_expiration"=>"181", "deactivation_date"=>nil, "description"=>"Rent eBook (180 days)", "description_limit"=>"180 days", "id"=>87541, "is_limited"=>true, "limit_days"=>180, "other_pricing"=>nil, "price"=>"108.03"}], "drm"=>{"copy_percentage"=>nil, "offline_percent"=>"0.100", "offline_range"=>nil, "print_allowance_percent"=>"0.000", "print_allowance_range"=>"", "sample_page_end"=>0, "sample_percentage"=>"0.000"}, "edition_number"=>9, "files"=>{"cover_image"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/cover_image/0321558235.jpg"}, "thumbnail"=>{"filename"=>"0321558235.jpg", "url"=>"//content.redshelf.com/site_media/media/thumbnail/0321558235.jpg"}}, "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "identifiers"=>{"eisbn10"=>"032183030X", "eisbn13"=>"9780321830302", "hash_id"=>"fb02181f26270f72e261de20f8aadb9096f40802", "id"=>62886, "isbn10"=>"0321558235", "isbn13"=>"9780321558237", "parent_isbn"=>nil, "sku"=>nil}, "language"=>"", "num_pages"=>1464, "publish_year"=>nil, "status"=>{"is_active"=>true, "is_html"=>true, "is_processed"=>true, "is_public"=>true, "is_published"=>true, "is_queued"=>true, "processed_date"=>"2014-11-21T11:12:22.296Z", "queued_date"=>"2014-11-20T15:57:57.960Z"}, "subtitle"=>"", "title"=>"Campbell Biology, 9/e", "website_url"=>""}
          ] * 1
        }
      }
      
      subject { client.book_index {|book| yield_output << book } }
    
      it 'makes multiple requests to redshelf and yields the results' do
        subject
        expect(yield_output.size).to eq(3)
        expect(yield_output.map(&:author)).to eq(['Lisa A. Urry 1', 'Lisa A. Urry 1', 'Lisa A. Urry 2'])
      end
    end
  
  end
  
  describe "Normalization" do
    describe "normalize_price" do
      
      subject { client.normalize_price(price) }
      
      context "price in cents integer" do
        let(:price) { 1201 }
        
        it "should return the price as dollars string" do
          expect(subject).to eq("12.01")
        end
      end
      
      context "price in cents string" do
        let(:price) { '1200' }
        
        it "should return the price as dollars string" do
          expect(subject).to eq("12.00")
        end
      end
      
      context "price in dollars string" do
        let(:price) { '12.01' }
        
        it "should return the price as dollars string" do
          expect(subject).to eq("12.01")
        end
      end
      
      context "small prices" do
        context "price in cents integer" do
          let(:price) { 1 }
        
          it "should return the price as dollars string" do
            expect(subject).to eq("0.01")
          end
        end
      
        context "price in cents string" do
          let(:price) { '1' }
        
          it "should return the price as dollars string" do
            expect(subject).to eq("0.01")
          end
        end
      
        context "price in dollars string" do
          let(:price) { '0.01' }
        
          it "should return the price as dollars string" do
            expect(subject).to eq("0.01")
          end
        end
      end
      
    end
  end

end
