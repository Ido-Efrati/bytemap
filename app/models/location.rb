class Location < ActiveRecord::Base
	has_many :offerings, dependent: :destroy
	has_many :subscriptions


	#get a locaion id if the location already exists in the location table. Otherwise, creates the location
	#@param - given a location object that may not been already saved
	#return the location id
	def self.get_or_create_id(location) 
		if !Location.exists?(customid: location.customid)
			location.save()
			locationid = location.id
		else
			@mylocation = Location.find_by_customid(location.customid)
			locationid = @mylocation.id
		end
		return locationid
	end


	#create from the response, if the location already exists, then don't save
  	#return the location_id
	def self.create_from_whereis(response)
		@newLocation = Location.new
        @newLocation.latitude = response["lat_wgs84"]
        @newLocation.longitude = response["long_wgs84"]
        @newLocation.title = response["name"]
        @newLocation.customid = response["id"]
        @newLocation.building_number = response["bldgnum"]
        @newLocationid = Location.get_or_create_id(@newLocation)

        return [@newLocationid, @newLocation.customid]
	end

	#get location display string for infowindow
	def get_title_description()
		if !self.building_number.nil?
			if self.title.include? self.building_number
				return "Building " + self.building_number
			else
				return "Building " + self.building_number + "- " + self.title
			end
		else
			return self.title
		end
	end

	# returns true if this location has no more offerings
	def isEmpty?
		return self.offerings.count == 0
	end
end