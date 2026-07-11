# This migration comes from noticed (originally 20231215190233), adapted to
# this app's UUID primary keys.
class CreateNoticedTables < ActiveRecord::Migration[8.1]
  def change
    create_table :noticed_events, id: :uuid do |t|
      t.string :type
      t.belongs_to :record, polymorphic: true, type: :uuid
      t.jsonb :params
      t.integer :notifications_count

      t.timestamps
    end

    create_table :noticed_notifications, id: :uuid do |t|
      t.string :type
      t.belongs_to :event, null: false, type: :uuid
      t.belongs_to :recipient, polymorphic: true, null: false, type: :uuid
      t.datetime :read_at
      t.datetime :seen_at

      t.timestamps
    end

    add_index :noticed_notifications, :read_at
    add_foreign_key :noticed_notifications, :noticed_events, column: :event_id
  end
end
