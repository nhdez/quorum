class CreateRanks < ActiveRecord::Migration[8.1]
  def change
    create_table :ranks, id: :uuid do |t|
      t.string :name, null: false
      t.integer :tier, null: false
      t.string :badge_color, null: false, default: "#8a6d1f"

      t.timestamps
    end

    add_index :ranks, :tier, unique: true

    create_table :rank_conditions, id: :uuid do |t|
      t.uuid :rank_id, null: false
      t.string :metric, null: false
      t.integer :threshold, null: false

      t.timestamps
    end

    add_index :rank_conditions, :rank_id
    add_foreign_key :rank_conditions, :ranks
  end
end
