class CreateFallacyFlags < ActiveRecord::Migration[8.1]
  def change
    create_table :fallacy_flags, id: :uuid do |t|
      t.string :flaggable_type, null: false
      t.uuid :flaggable_id, null: false
      t.uuid :fallacy_definition_id, null: false
      t.text :excerpt, null: false
      t.float :confidence, null: false
      t.boolean :visible_publicly, null: false, default: false
      t.boolean :dismissed_by_author, null: false, default: false
      t.datetime :created_at, null: false
    end

    add_index :fallacy_flags, [ :flaggable_type, :flaggable_id ]
    add_foreign_key :fallacy_flags, :fallacy_definitions
  end
end
