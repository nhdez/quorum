class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes, id: :uuid do |t|
      t.string :votable_type, null: false
      t.uuid :votable_id, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end

    add_index :votes, [ :votable_type, :votable_id, :user_id ], unique: true, name: "index_votes_uniqueness"
    add_index :votes, [ :votable_type, :votable_id ]
    add_foreign_key :votes, :users
  end
end
