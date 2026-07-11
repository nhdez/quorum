class AddColorToFactions < ActiveRecord::Migration[8.1]
  def change
    add_column :factions, :color, :string, null: false, default: "#7a7a7a"
  end
end
