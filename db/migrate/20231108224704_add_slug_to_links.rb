class AddSlugToLinks < ActiveRecord::Migration[7.1]
  def change
    add_column :links, :slug, :string
    add_index :links, :slug, unique: true
  end
end
