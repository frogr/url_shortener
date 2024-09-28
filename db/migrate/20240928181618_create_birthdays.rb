class CreateBirthdays < ActiveRecord::Migration[7.1]
  def change
    create_table :birthdays do |t|
      t.string :user_id, null: false
      t.date :birthday, null: false

      t.timestamps
    end
  end
end
