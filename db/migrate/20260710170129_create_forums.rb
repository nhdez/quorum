class CreateForums < ActiveRecord::Migration[8.1]
  def change
    create_table :forums, id: :uuid do |t|
      t.references :forum_category, null: false, foreign_key: true, type: :uuid
      t.integer :index_order
      t.string :title
      t.text :description
      t.decimal :affiliation_factor, default: 1
      t.boolean :is_visible, default: true
      t.string :slug, null: false

      t.timestamps
    end

    add_index :forums, :slug, unique: true
  end
end
