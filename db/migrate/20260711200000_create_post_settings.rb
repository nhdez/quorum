class CreatePostSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :post_settings, id: :uuid do |t|
      t.integer :max_word_count

      t.timestamps
    end
  end
end
