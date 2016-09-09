class Subscription < ActiveRecord::Base
	has_one :location

	#checks if the user is subscribed to a given location, we want to make sure
	# a subscription does not exist. If one exist we don't want to let the user subscribe again
	def self.subscribed(mitlocation,user_id)
		return !Subscription.exists?(mitlocation_id: mitlocation, user_id: user_id)
	end

	#first gets the id from the location and call subscribed. This is for incoming emails only

	def self.getSubscribedId(mitlocation, user_id)
		if !Subscription.where(mitlocation_id: mitlocation, user_id:user_id).first.nil?
			return Subscription.where(mitlocation_id: mitlocation, user_id:user_id).first.id
		else
			return -1 # you don't have a subscription
		end
	end
end
