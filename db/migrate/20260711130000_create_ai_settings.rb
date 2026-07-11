class CreateAiSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :ai_settings, id: :uuid do |t|
      t.string :api_key
      t.string :model_id, null: false, default: "claude-opus-4-8"

      t.timestamps
    end
  end
end
