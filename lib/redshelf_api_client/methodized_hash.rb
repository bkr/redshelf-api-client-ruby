require 'active_support/hash_with_indifferent_access'

class RedshelfApiClient::MethodizedHash < ActiveSupport::HashWithIndifferentAccess
  
  def self.from(maybe_hash)
    if maybe_hash.is_a?(Hash)
      return self.new(maybe_hash)
    elsif maybe_hash.is_a?(Array)
      return maybe_hash.map{|mh| self.from(mh) }
    else
      return maybe_hash
    end
  end

  def initialize(hash={})
    super(hash)
    _methodize
  end

  private

  def _methodize
    metaclass = class << self; self; end
    each do |k, v|
      unless respond_to?(k.to_s)
        metaclass.send(:define_method, k.to_s) { self.class.from(self[k]) }
        metaclass.send(:define_method, "#{k}=") {|value| self[k]=value } unless respond_to?("#{k}=")
        metaclass.send(:define_method, "#{k}?") { !!self[k] } unless respond_to?("#{k}?")
      end
    end
  end
end