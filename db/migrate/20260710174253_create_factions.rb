class CreateFactions < ActiveRecord::Migration[8.1]
  def change
    create_table :factions, id: :uuid do |t|
      t.string :name
      t.text :description
      t.boolean :is_active, default: true

      t.timestamps
    end
  end
end
