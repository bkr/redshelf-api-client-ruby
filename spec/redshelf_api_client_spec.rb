require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ostruct'

describe "RedshelfApiClient" do
  let(:response_headers) { {} }
  let(:response_code) { 200 }
  let(:response_body) { response_hash.to_json }
  let(:redshelf_response) { OpenStruct.new(:body => response_body, :code => response_code, :headers => response_headers) }
  let(:client) { RedshelfApiClient.new }
  
  before do
    allow_any_instance_of(::RestClient::Request).to receive(:execute).and_yield(redshelf_response)
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
end
