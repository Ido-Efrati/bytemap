class AddNumDeleteVotesToOfferings < ActiveRecord::Migration
  def change
    add_column :offerings, :numDeleteVotes, :integer
  end
end
