class AddInboxCountToInboxes < ActiveRecord::Migration[5.0]
  def change
  	add_column :inboxes, :inbox_count, :integer, default: 0
  end
end
