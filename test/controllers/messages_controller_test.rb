require 'test_helper'

class MessagesControllerTest < ActionController::TestCase
	def setup
		# Updating these attributes here because boolean values set in the
		# YAML fixture files return nil when used as a scope through the ORM.
		users(:patient).update_attributes(is_patient: true)
		users(:doctor).update_attributes(is_patient: false, is_doctor: true)
		users(:admin).update_attributes(is_patient: false, is_admin:true)

		@message = Message.create(body: 'Thanks for your order. I will in touch shortly after reviewing your treatment application.',
            outbox: User.default_doctor.outbox,
            inbox: User.current.inbox)

		@message_more_than_a_week = Message.create(body: 'Thanks for your order.',
        	outbox: User.default_doctor.outbox,
          	inbox: User.current.inbox,
          	created_at: DateTime.current.in_time_zone.weeks_ago(2))
	end

	def test_message_gets_created_successfully
		message_body = "Thanks for a great medical observation"
		post :create, params: { message: { body: message_body }, associated_message_id: @message.id }

		assert_response :redirect
		assert_redirected_to messages_url

		created_message = Message.find_by(body: message_body)
		assert_not_nil created_message

		# A message has an unread status after creation
		refute created_message.read

		# A message is sent to the correct inbox and outbox after creation
		assert_equal created_message.inbox, User.default_doctor.inbox
		assert_equal created_message.outbox, User.current.outbox

		# That the number of unread messages is incremented when a doctor is sent a message
		doctor_inbox_before_send = Inbox.find_by(user: User.default_doctor.id)
		message_body = "Wonderful checkup!!!"
		post :create, params: { message: { body: message_body }, associated_message_id: @message.id }

		assert_equal doctor_inbox_before_send.inbox_count + 1,
			Inbox.find_by(user: User.default_doctor.id).reload.inbox_count

		assert_equal "Your message has been sent!", flash[:success]

		# Message goes to admin when the message is older than 1 week
		post :create, params: { message: { body: message_body }, associated_message_id: @message_more_than_a_week.id }
		assert_equal Message.last.inbox, Inbox.default_admin_inbox
	end

	def test_resend_script
		assert_nil Payment.find_by(user_id: User.current.id)

		post :resend_script, params: { id: @message.id }

		assert_response :redirect
		assert_redirected_to messages_url

		# A lost script message is sent to the admin
		assert_equal "I've lost my script, please issue a new one at a charge of €10.",
			User.default_admin.inbox.messages.last.body

		assert_equal "Script re-issue request has been sent!", flash[:success]

		# The Payment API is called and Payment Record is created
		assert_not_nil Payment.find_by(user_id: User.current.id)
	end

	def test_show
		message_body = "Thanks for a great medical observation doc!!!"
		post :create, params: { message: { body: message_body }, associated_message_id: @message.id }

		inbox_count_before_read = Inbox.find_by(user: User.default_doctor).inbox_count

		get :show, params: { id: Inbox.find_by(user: User.default_doctor).messages.first.id }

		assert_response :success

		# That the number of unread messages is decremented when a doctor reads a message
		assert_equal inbox_count_before_read - 1, Inbox.find_by(user: User.default_doctor).reload.inbox_count
	end
end