class MessagesController < ApplicationController

	def show
		MessageService.new(params[:id]).read_message
		@message = Message.find(params[:id])
	end

	def new
		@message = Message.new
		@associated_message_id = params[:associated_message_id]
	end

	def create
		@message = NewMessageService.new(
						message_params[:body],
						User.current,
						User.default_doctor,
						params[:message][:associated_message_id]).call

		if @message.save
			flash[:success] = "Your message has been sent!"
      		redirect_to action: :index
      	else
      		flash[:failure] = "Please try again."
      		render :new
		end
	end

	def resend_script
		@message = User.default_admin.inbox.messages.new
		@message.outbox = User.current.outbox
		@message.body = "I've lost my script, please issue a new one at a charge of €10."

		if @message.save
			::PaymentProviderFactory.provider.debit_card(User.current)
			flash[:success] = "Script re-issue request has been sent!"
      		redirect_to action: :index
      	else
      		flash[:failure] = "Could not send request. Please try again."
      		redirect_to action: :show, id: params[:id]
		end
	end

    private

    def message_params
      	params.require(:message).permit(:body)
    end

end
