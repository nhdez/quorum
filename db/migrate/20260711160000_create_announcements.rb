class CreateAnnouncements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements, id: :uuid do |t|
      t.text :text, null: false
      t.boolean :active, null: false, default: true

      t.timestamps
    end
  end
end
