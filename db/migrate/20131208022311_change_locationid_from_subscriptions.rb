class ChangeLocationidFromSubscriptions < ActiveRecord::Migration
  def change
  	add_column :subscriptions, :mitlocation_id, :string
  	remove_column :subscriptions, :location_id
  end
end
