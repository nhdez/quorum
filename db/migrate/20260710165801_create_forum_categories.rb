class CreateForumCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :forum_categories, id: :uuid do |t|
      t.string :title
      t.text :description
      t.integer :index_order
      t.boolean :is_visible, default: true
      t.decimal :affiliation_factor, default: 1
      t.string :slug, null: false

      t.timestamps
    end

    add_index :forum_categories, :slug, unique: true
  end
end
