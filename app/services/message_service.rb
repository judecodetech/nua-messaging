class MessageService

  def initialize(message_id)
    raise ArgumentError.new("You must provide a message id.") if message_id.nil?
    @message = Message.find(message_id)
  end

  def mark_as_read!
    @message.mark_as_read!
  end
  
end