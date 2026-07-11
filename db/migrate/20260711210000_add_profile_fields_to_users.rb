class AddProfileFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :country_code, :string
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :motto, :string
    add_column :users, :public_email, :string
    add_column :users, :website_url, :string
    add_column :users, :date_of_birth, :date
    add_column :users, :signature, :text
    add_column :users, :signature_pending_review, :boolean, null: false, default: false
  end
end
