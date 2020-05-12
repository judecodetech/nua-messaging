class NewMessageService
  def initialize(body, sender, recipient, associated_message_id)
    @body = body
    @sender = sender
    @recipient = @recipient
    @associated_message_id = associated_message_id
    @inbox = message_created_in_past_week ? recipient.inbox : User.default_admin.inbox
  end

  def call
    Message.new(body: @body, inbox: @inbox, outbox: @sender.outbox)
  end

  private

  def message_created_in_past_week
      Message.created_in_past_week(@associated_message_id) 
  end 
end