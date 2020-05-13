class PaymentProviderFactory
  def self.provider
    @provider ||= Provider.new
  end

  class Provider
  	def debit_card(user)
  			Payment.create!(user: user)
        return { success: true }
  	end
  end
end
