class AddInboxCountToInboxes < ActiveRecord::Migration[5.0]
  def change
  	add_column :inboxes, :unread_messages, :integer, default: 0
  end
end
