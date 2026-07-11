class AddAuthorshipAndViewsToThreads < ActiveRecord::Migration[8.1]
  def change
    add_reference :forum_threads, :user, null: false, foreign_key: true, type: :uuid
    add_column :forum_threads, :views_count, :integer, default: 0, null: false

    add_reference :thread_replies, :user, null: false, foreign_key: true, type: :uuid
  end
end
