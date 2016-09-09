class Offering < ActiveRecord::Base

	include PublicActivity::Common

	has_one :location
	belongs_to :user
	validates :sub_location, presence: true
	validates :description, presence: true

  # destroys an offering
  # also destroys the location if the location becomes empty as a result of the offering deletion
  # returns true if this offering's location was destroyed
	def custom_destroy
	  self.destroy  
      # destroy location if no more offerings in this location
      location = Location.find(self.location_id)
	  if location.isEmpty?
        location.destroy
        return true
      else
        return false
      end
	end

	# Deletes stale offerings (created more than 20 minutes / 1200 seconds ago) from the database. 
	# This method is called by a cron job every 10 minutes (made short so that the staff can test if they'd like)
	# To run this just once immediately,  type "heroku run rake remove_stale_offerings" into console
	def self.remove_stale
		self.all.each do |offer|
			if offer.is_stale?(1200)
				offer.custom_destroy
			end
		end
	end

	# returns true if this offering was created more than grace_period number of seconds ago 
	def is_stale?(grace_period)
		seconds_elapsed = Time.now - self.created_at
		return seconds_elapsed > grace_period
	end

	#registers a vote and marks the user as having voted
	def vote_to_destroy(session)
		self.increment!(:numDeleteVotes)
		session[:votes].push(self.id)
	end

	# returns true if this offering has received an adequate number of "votes" 
	# such that it should be deleted 
	def sufficient_votes?
		return self.numDeleteVotes >= 3
	end
end
