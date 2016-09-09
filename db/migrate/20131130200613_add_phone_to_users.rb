class AddPhoneToUsers < ActiveRecord::Migration
  def change
  	    add_column :users, :phoneNumber, :integer, :limit => 8
  	    add_column :users, :provider, :string
  end
end
