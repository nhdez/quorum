class CreateFallacyScopeSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :fallacy_scope_settings, id: :uuid do |t|
      t.uuid :fallacy_definition_id, null: false
      t.string :scope_type, null: false
      t.uuid :scope_id, null: false
      t.boolean :enabled
      t.float :confidence_threshold

      t.timestamps
    end

    add_index :fallacy_scope_settings, [ :fallacy_definition_id, :scope_type, :scope_id ], unique: true, name: "index_fallacy_scope_settings_uniqueness"
    add_index :fallacy_scope_settings, [ :scope_type, :scope_id ]
    add_foreign_key :fallacy_scope_settings, :fallacy_definitions
  end
end
