class CreateBlips < ActiveRecord::Migration[6.0]
  def change
    create_table :blips do |t|
      t.text :content
      t.string :unique_url

      t.timestamps
    end
    add_index :blips, :unique_url, unique: true
  end
end
