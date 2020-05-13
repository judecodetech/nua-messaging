class ResendScriptService
   LOST_PRESCRIPTION_MESSAGE = "I've lost my script, please issue a new one at a charge of €10."

  def initialize(issuer, receiver: User.default_admin)
    @receiver = receiver
    @issuer = issuer
  end

  def process
    response = ::PaymentProviderFactory.provider.debit_card(@issuer)
    send_prescription_request_message if response[:success]
    response
  end

  private

  def send_prescription_request_message
    Message.create(
      body: LOST_PRESCRIPTION_MESSAGE,
      outbox: @issuer.outbox,
      inbox: @receiver.inbox
    )
  end
end