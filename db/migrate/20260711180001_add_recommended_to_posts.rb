class AddRecommendedToPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :forum_threads, :recommended, :boolean, null: false, default: false
    add_column :thread_replies, :recommended, :boolean, null: false, default: false
  end
end
