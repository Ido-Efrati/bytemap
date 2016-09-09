class CreateOfferings < ActiveRecord::Migration
  def change
    create_table :offerings do |t|
      t.integer :owner_id
      t.integer :location_id
      t.string :sub_location
      t.string :description
      t.timestamp :last_seen
      t.timestamps
    end
  end
end
