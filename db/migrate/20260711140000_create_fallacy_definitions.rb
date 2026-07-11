class CreateFallacyDefinitions < ActiveRecord::Migration[8.1]
  def change
    create_table :fallacy_definitions, id: :uuid do |t|
      t.string :key, null: false
      t.string :display_name, null: false
      t.text :short_description, null: false
      t.text :long_description, null: false
      t.text :detection_prompt_fragment, null: false
      t.boolean :default_enabled, null: false, default: true
      t.float :default_confidence_threshold, null: false, default: 0.6
      t.integer :default_severity, null: false, default: 1

      t.timestamps
    end

    add_index :fallacy_definitions, :key, unique: true
  end
end
