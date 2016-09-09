require 'test_helper'

class SubscriptionTest < ActiveSupport::TestCase

    #checks if the user is subscribed to a given location, we want to make sure
	# a subscription does not exist. If one exist we don't want to let the user subscribe again
    def test_subscribed
    	@subscription = Subscription.new
    	@subscription.user_id = 1
    	@subscription.mitlocation_id = "test"
 	  	@subscription.save
        assert_equal false, Subscription.subscribed("test",1)
        assert_equal true, Subscription.subscribed("test33333",133333)
    end

end
