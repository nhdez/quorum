class CreateUserGroups < ActiveRecord::Migration[8.1]
  def change
    create_table :user_groups, id: :uuid do |t|
      t.string :name, null: false
      t.string :badge_color, null: false, default: "#333333"
      t.boolean :system_group, null: false, default: false
      t.integer :index_order

      t.timestamps
    end

    add_index :user_groups, :name, unique: true
  end
end
