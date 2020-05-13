class MessagesController < ApplicationController

	def show
		MessageService.new(params[:id]).mark_as_read!
		@message = Message.find(params[:id])
	end

	def new
		@message = Message.new
	end

	def create
		@message = new_message

		if @message.save
			flash[:success] = "Your message has been sent!"
      		redirect_to messages_path
      	else
      		flash[:failure] = "An error occured. Please try again."
      		render action: :new
		end
	end

	def resend_script
		response = ResendScriptService.new(User.current).process

		if response[:success]
			flash[:success] = "Script re-issue request has been sent!"
      		redirect_to messages_path
      	else
      		flash[:failure] = "Could not send request. Please try again."
      		redirect_to message_path(params[:id])
		end
	end

    private

    def new_message
    	message = Message.new(message_params)
    	message.outbox = User.current.outbox
    	message.inbox = Message.find(params[:associated_message_id]).receiver_inbox
    	message
    end

    def message_params
      	params.require(:message).permit(:body)
    end

end
