# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: redshelf-api-client-ruby 0.1.4 ruby lib

Gem::Specification.new do |s|
  s.name = "redshelf-api-client-ruby"
  s.version = "0.1.4"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["Andrew Wheeler"]
  s.date = "2015-05-28"
  s.description = "Facilitates connection and requests to the Redshelf API, you know, for ebooks."
  s.email = "j.andrew.wheeler@gmail.com"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.md"
  ]
  s.files = [
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/redshelf-api-client-ruby.rb",
    "lib/redshelf_api_client/base.rb",
    "lib/redshelf_api_client/builder.rb",
    "lib/redshelf_api_client/methodized_hash.rb",
    "lib/redshelf_api_client/normalization.rb",
    "lib/redshelf_api_client/requests.rb",
    "lib/rest_builder.rb",
    "lib/rest_builder/builder.rb",
    "lib/rest_builder/connection_error.rb",
    "lib/rest_builder/error.rb",
    "lib/rest_builder/json_content.rb",
    "lib/rest_builder/request.rb",
    "lib/rest_builder/response.rb",
    "lib/rest_builder/response_error.rb",
    "lib/rest_builder/rest_client.rb",
    "lib/rest_builder/url_component.rb",
    "redshelf-api-client-ruby.gemspec",
    "spec/redshelf_api_client_spec.rb",
    "spec/spec_helper.rb",
    "spec/test.pem"
  ]
  s.homepage = "http://github.com/jawheeler/redshelf-api-client-ruby"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Facilitate connection and requests to the Redshelf API."

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_runtime_dependency(%q<rest-client>, [">= 1.6.7", "~> 1.6"])
      s.add_runtime_dependency(%q<activesupport>, [">= 4.1.9", "~> 4.1"])
      s.add_runtime_dependency(%q<activemodel>, [">= 4.1.9", "~> 4.1"])
      s.add_runtime_dependency(%q<i18n>, [">= 0.7.0", "~> 0.7"])
      s.add_development_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0"])
    else
      s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
      s.add_dependency(%q<rest-client>, [">= 1.6.7", "~> 1.6"])
      s.add_dependency(%q<activesupport>, [">= 4.1.9", "~> 4.1"])
      s.add_dependency(%q<activemodel>, [">= 4.1.9", "~> 4.1"])
      s.add_dependency(%q<i18n>, [">= 0.7.0", "~> 0.7"])
      s.add_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0"])
    end
  else
    s.add_dependency(%q<rake>, [">= 10.4.2", "~> 10.4"])
    s.add_dependency(%q<rest-client>, [">= 1.6.7", "~> 1.6"])
    s.add_dependency(%q<activesupport>, [">= 4.1.9", "~> 4.1"])
    s.add_dependency(%q<activemodel>, [">= 4.1.9", "~> 4.1"])
    s.add_dependency(%q<i18n>, [">= 0.7.0", "~> 0.7"])
    s.add_dependency(%q<jeweler>, [">= 2.0.1", "~> 2.0"])
  end
end

