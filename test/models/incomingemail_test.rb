require 'test_helper'

class IncomingemailTest < ActiveSupport::TestCase
   	#test if we are not creating duplicated names as well as 
	#undefined names, if a building does not have a building number 
	test "parse_email_subject" do
		@info = Incomingemail.parseEmail("where:a, what:cookies")
		assert @info[0] == "a"
		assert @info[2] == "cookies"

		@info = Incomingemail.parseEmail("Where:a, what   :cookies")
		assert @info[0] == "a"
		assert @info[2] == "cookies" 

		@info = Incomingemail.parseEmail("where:a  ,    what:cookies")
		assert @info[0] == "a  "
		assert @info[2] == "cookies"

		@info = Incomingemail.parseEmail("   what:cookies")
		assert @info[0] == nil
		assert @info[2] == "cookies"

		@info = Incomingemail.parseEmail(" ")
		assert @info[0] == nil
		assert @info[2] == nil

	end

	test "check_correct_email" do
		assert Incomingemail.correctToEmail("where:a, what:cookies") == false
		assert Incomingemail.correctToEmail("3dcfe1f5df7214a766f7@cloudmailin.net") == true
	end

end
