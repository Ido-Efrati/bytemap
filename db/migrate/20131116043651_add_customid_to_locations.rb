class AddCustomidToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :customid, :string
  end
end
