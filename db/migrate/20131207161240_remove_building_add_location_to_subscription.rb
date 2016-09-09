class RemoveBuildingAddLocationToSubscription < ActiveRecord::Migration
  def change
  	    remove_column :subscriptions, :building_id, :integer
  	    add_column :subscriptions, :location_id, :integer
  end
end
