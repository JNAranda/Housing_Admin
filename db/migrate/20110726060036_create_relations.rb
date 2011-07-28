class CreateRelations < ActiveRecord::Migration
  def self.up
    create_table :relations do |t|
      t.integer :follower_id
      t.integer :stalked_id

      t.timestamps
    end
    add_index :relations, :follower_id
    add_index :relations, :stalked_id
    add_index :relations, [:follower_id, :stalked_id], :unique => true
  end

  def self.down
    drop_table :relations
  end
end
