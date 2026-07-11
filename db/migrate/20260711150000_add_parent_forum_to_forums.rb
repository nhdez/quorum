class AddParentForumToForums < ActiveRecord::Migration[8.1]
  def change
    add_column :forums, :parent_forum_id, :uuid
    add_index :forums, :parent_forum_id
    add_foreign_key :forums, :forums, column: :parent_forum_id
  end
end
