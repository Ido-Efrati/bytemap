require 'test_helper'

class UserTest < ActiveSupport::TestCase

    #test that we convert the provider to the right provider getway
    def test_provider_to_email
        user1 = users(:user_one)
        user2 = users(:user_two)
        user3 = users(:user_three)
        user4 = users(:user_four)
        assert_equal "@tmomail.net", user1.provider_to_email(user1.provider)
        assert_equal "@txt.att.net", user2.provider_to_email(user2.provider)
        assert_equal "@vtext.com", user3.provider_to_email(user3.provider)
        assert_equal nil, user4.provider_to_email(user4.provider)
    end

    #test that given a phone number and a provider we can create a text mail
    def test_get_text_address
        user1 = users(:user_one)
        user2 = users(:user_two)
        user3 = users(:user_three)

        user1.provider = user1.provider_to_email(user1.provider)
        user2.provider = user2.provider_to_email(user2.provider)
        user3.provider = user3.provider_to_email(user3.provider)
        
        assert_equal "1231231234@tmomail.net", user1.get_text_address()
        assert_equal "8571231234@txt.att.net", user2.get_text_address()
        assert_equal "6171231234@vtext.com", user3.get_text_address()
    end  

    #test our ajax call to MIT people with a kerberos 
    def test_get_MIT_people_email
        user1 = users(:user_one)
        assert_equal true, user1.get_MIT_people_email().include?(user1.email)
    end

    #test if a user can subscribe or not
    def test_can_subscribe?
        user1 = users(:user_one)
        user2 = users(:user_two)
        user3 = users(:user_three)
        user4 = users(:user_four)
        assert_equal true, user1.can_subscribe?()
        assert_equal true, user2.can_subscribe?()
        assert_equal true, user3.can_subscribe?()
        assert_equal false, user4.can_subscribe?()
     end

     #get the userid and if the user can subscribe to a location
     test "get_subscriptionInfo" do
        user1 = nil
        user2 = users(:user_one)
        user3 = users(:user_four)
        user4 = users(:user_three)

        info1 = User.get_subscriptionInfo(user1)
        info2 = User.get_subscriptionInfo(user2)
        info3 = User.get_subscriptionInfo(user3)
        info4 = User.get_subscriptionInfo(user4)

        assert_equal info1[0], -1
        assert_equal info1[1], false

        assert_equal info2[0], user2.id
        assert_equal info2[1], true

        assert_equal info3[0], user3.id
        assert_equal info3[1], false

        assert_equal info4[0], user4.id
        assert_equal info4[1], true
     end
end
