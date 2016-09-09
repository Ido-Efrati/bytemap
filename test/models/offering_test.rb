require 'test_helper'

class OfferingTest < ActiveSupport::TestCase

  #test that we can only destroy a location if it does not have
  #any offferings
  test "custom_destroy" do
  	# location with one offering
  	@location = make_location()
  	@offering = make_offering(@location.id)

    assert @offering.custom_destroy == true

    # location with two offerings
  	@location = make_location()
  	@offering1 = make_offering(@location.id)
   	@offering2 = make_offering(@location.id) 	
   	assert @offering1.custom_destroy == false
   	assert @offering2.custom_destroy == true
  end

  #test if an offering is older than 5 mins. so we will be able
  #to destroy it later
  test "is_stale" do
  	#create an offering and save it
  	@offering = make_offering(1)

  	assert @offering.is_stale?(0) == true
  	assert @offering.is_stale?(-1) == true
  	assert @offering.is_stale?(30) == false
  end

  #test that we can register the votes of a user
  test "vote to destroy" do
  	session = {}
  	session[:votes] = []

  	#create a lightweight offering (without all the fields completed)
    @offering = Offering.new
    @offering.numDeleteVotes = 0
    @offering.location_id = 1

  	assert session[:votes].index(@offering.id) == nil

  	# vote on an offering
  	@offering.vote_to_destroy(session)

  	assert @offering.numDeleteVotes == 1
  	assert session[:votes].index(@offering.id) >= 0
  end

  #test if we have enough votes to clear an offering
  test "sufficient_votes" do
  	session = {}
  	session[:votes] = []

    @offering = Offering.new
    @offering.numDeleteVotes = 0
    assert @offering.sufficient_votes? == false

    @offering.vote_to_destroy(session)
    assert @offering.sufficient_votes? == false

    @offering.vote_to_destroy(session)
    @offering.vote_to_destroy(session)
    assert @offering.sufficient_votes? == true 
  end



  def make_location
  	@location = Location.new
  	@location.latitude = 1.1
  	@location.longitude = 1.1
  	@location.title = "Stata"
  	@location.customid = "test"
  	@location.building_number = "test"
  	@location.save
  	return @location
  end


  def make_offering(loc_id)
    @offering = Offering.new
    @offering.owner_id = 1
    @offering.location_id = loc_id
    @offering.numDeleteVotes = 0
    @offering.sub_location = "test"
    @offering.description = "test"
    @offering.last_seen = Time.now
    @offering.save
    return @offering
  end

end
