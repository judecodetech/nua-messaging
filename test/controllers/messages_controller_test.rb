require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
	def setup
		@patient = create(:user, :patient)
		@doctor = create(:user, :doctor)
		@admin = create(:user, :admin)

		@message_params = FactoryBot.attributes_for(:message)

		@doctor_message =  create(:message, {
 			outbox: @doctor.outbox,
        	inbox: @patient.inbox
        })
	end

	def test_that_it_creates_message_with_unread_status
		create_message_through_post(@doctor_message.id)
		refute Message.last.read
	end

	def test_that_a_message_is_sent_to_the_correct_inbox_and_outbox_after_creattion
		create_message_through_post(@doctor_message.id)

		assert_equal Message.last.inbox, @doctor.inbox
		assert_equal Message.last.outbox, @patient.outbox
	end

	def test_that_message_goes_to_doctor_when_the_message_is_not_older_than_one_week
		create_message_through_post(@doctor_message.id)
		assert Message.last.inbox.user.is_doctor
	end

	def test_that_message_goes_to_admin_when_the_message_is_older_than_one_week
		doctor_message_sent_more_than_a_week_ago =  create(:message, :sent_1_week_ago, {
 			outbox: @doctor.outbox,
        	inbox: @patient.inbox
        })
		create_message_through_post(doctor_message_sent_more_than_a_week_ago.id)
		assert Message.last.inbox.user.is_admin
	end

	def test_that_the_number_of_unread_messages_is_incremented_when_a_doctor_is_sent_a_message
		before_create_unread_messages = @doctor.inbox.unread_messages
		create_message_through_post(@doctor_message.id)
		assert_operator @doctor.inbox.reload.unread_messages, :>, before_create_unread_messages 
	end

	def test_that_unread_messages_is_decremented_when_a_doctor_reads_a_message
		message =  create(:message, {
 			outbox: @patient.outbox,
        	inbox: @doctor.inbox
        })

        before_read_unread_messages = @doctor.inbox.reload.unread_messages

		get :show, params: { id: message.id }
		assert_operator @doctor.inbox.reload.unread_messages, :<, before_read_unread_messages
	end

	def test_that_unread_messages_is_incremented_when_a_doctor_receives_a_message

	end

	def test_resend_script
		assert_nil Payment.find_by(user_id: @patient.id)

		post :resend_script, params: { id: @doctor_message.id }

		assert_response :redirect
		assert_redirected_to messages_url

		# A lost script message is sent to the admin
		assert_equal ResendScriptService::LOST_PRESCRIPTION_MESSAGE,
			@admin.inbox.messages.last.body

		assert_not_nil flash[:success]

		# Payment Record is created
		assert_not_nil Payment.find_by(user_id: @patient.id)
	end

	def test_application_degrades_gracefully_when_the_payment_api_fails
		ResendScriptService.any_instance.stubs(:process).returns({success: false})

		assert_nil flash[:failure]

		post :resend_script, params: { id: @doctor_message.id }

		assert_not_nil flash[:failure]
	end

	private

	def create_message_through_post(associated_message_id)
		post :create, params: { message: @message_params, associated_message_id: associated_message_id }
	end
end