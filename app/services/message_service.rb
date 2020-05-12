class MessageService
  def initialize(message_id)
    raise ArgumentError.new("You must provide a message id.") if message_id.nil?
    @message = Message.find(message_id)
  end

  def read_message
    @message.read_message!
    @message.decrement_inbox_count!
  end

  private

  def message_created_in_past_week
      Message.created_in_past_week(@associated_message_id) 
  end 
end