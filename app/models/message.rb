class Message < ApplicationRecord
  after_create :increment_inbox_count!

  belongs_to :inbox
  belongs_to :outbox

  def increment_inbox_count!
    # Increment the inbox_count column for the record with an id of `self.inbox.id`
    Inbox.increment_counter(:inbox_count, self.inbox.id)
  end

  def decrement_inbox_count!
    Inbox.decrement_counter(:inbox_count, self.inbox.id)
  end

  def read_message!
    self.read = true
    self.save!
  end

  def self.created_in_past_week(id)
  	message = Message.find(id)

  	start_date = (Date.today - 7.days)

    # Now start_date is 1 week ago, and end_date is 1 week ago.
    # Test if created_at falls within this range
    Range.new(start_date.to_date, Date.today) === message.created_at.to_date
  end 

end