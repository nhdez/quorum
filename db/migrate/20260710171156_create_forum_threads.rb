class CreateForumThreads < ActiveRecord::Migration[8.1]
  def change
    create_table :forum_threads, id: :uuid do |t|
      t.references :forum, null: false, foreign_key: true, type: :uuid
      t.string :title
      t.boolean :is_draft, default: true
      t.boolean :is_sticky, default: false
      t.boolean :is_visible, default: true
      t.boolean :can_be_replied_to, default: true
      t.boolean :includes_poll, default: false
      t.datetime :expires_at
      t.string :slug, null: false

      t.timestamps
    end

    add_index :forum_threads, :slug, unique: true
  end
end
