class AddBldgnumberToLocations < ActiveRecord::Migration
  def change
  	    add_column :locations, :building_number, :string
  end
end
