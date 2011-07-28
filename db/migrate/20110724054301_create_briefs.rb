class CreateBriefs < ActiveRecord::Migration
  def self.up
    create_table :briefs do |t|
      t.text :content
      t.integer :user_id

      t.timestamps
    end
    add_index :briefs, :user_id
  end

  def self.down
    drop_table :briefs
  end
end
