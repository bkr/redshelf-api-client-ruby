
class RedshelfApiClient
  
  module Normalization

    def normalize_address(address)
      return nil if address.nil? || address.blank?
      {
        :first_name => address[:first_name], 
        :last_name => address[:last_name], 
        :line_1 => address[:line_1], 
        :line_2 => address[:line_2],
        :city => address[:city], 
        :state => address[:state], 
        :postal_code => address[:postal_code]
      }
    end
  
    def normalize_date(date)
      return nil if date.nil? || date.blank?
      Time.parse(date.to_s).strftime("%F %T") #FIXME???
    end
    
    def normalize_price(cents)
      string_cents = cents.to_s.sub(/\D/, '')
      sprintf("%0.2f", string_cents.to_i/100.0)
    end
    
  end
  
  include Normalization

end