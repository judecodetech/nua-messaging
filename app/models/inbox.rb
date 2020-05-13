class Inbox < ApplicationRecord

  belongs_to :user
  has_many :messages

  def self.default_admin_inbox
    User.default_admin.inbox
  end

end