class AddUsersToLinks < ActiveRecord::Migration[7.1]
  def change
    add_reference :links, :user, null: true, foreign_key: true
  end
end
