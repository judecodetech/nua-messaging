class Message < ApplicationRecord

  after_create :increment_inbox_unread_messages_counter!

  belongs_to :inbox
  belongs_to :outbox

  def receiver_inbox
    is_old_message? ? Inbox.default_admin_inbox : sender.inbox
  end

  def increment_inbox_unread_messages_counter!
    Inbox.increment_counter(:inbox_count, inbox.id)
  end

  def decrement_inbox_unread_messages_counter!
    Inbox.decrement_counter(:inbox_count, inbox.id)
  end

  def mark_as_read!
    unless read
      update(read: true)
      decrement_inbox_unread_messages_counter!
    end
  end

  def is_old_message?
    created_at.in_time_zone < ::DateTimeHelper.one_week_ago
  end

  private

  def sender
    outbox.user
  end

end