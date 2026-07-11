class CreateStorageSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :storage_settings, id: :uuid do |t|
      t.string :endpoint
      t.string :region
      t.string :bucket
      t.string :access_key_id
      t.string :secret_access_key
      t.boolean :force_path_style, null: false, default: true

      t.timestamps
    end
  end
end
