class PaymentProviderFactory
  def self.provider
    @provider ||= Provider.new
  end

  class Provider
  	def debit_card(user)
  		begin
  			Payment.create!(user: user)
  		rescue => e
  			# Would probably create an error log here
  			puts e.message  
  			puts e.backtrace.inspect  
  		end
  	end
  end
end
