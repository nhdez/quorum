class CreateSmtpSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :smtp_settings, id: :uuid do |t|
      t.string :address
      t.integer :port, default: 587
      t.string :domain
      t.string :user_name
      t.string :password
      t.string :authentication, default: "plain"
      t.boolean :enable_starttls_auto, null: false, default: true
      t.string :from_address

      t.timestamps
    end
  end
end
