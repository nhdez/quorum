class CreateThreadReplies < ActiveRecord::Migration[8.1]
  def change
    create_table :thread_replies, id: :uuid do |t|
      t.references :forum_thread, null: false, foreign_key: true, type: :uuid
      t.boolean :can_be_quoted, default: true

      t.timestamps
    end
  end
end
