class AddShowMyFallacyFlagsPubliclyToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :show_my_fallacy_flags_publicly, :boolean, null: false, default: false
  end
end
