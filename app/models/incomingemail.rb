class Incomingemail < ActiveRecord::Base

	#parsing an email subject line with a loose regex
	#[tag] : [info], [tag] : [info]
	def self.parseEmail(subject)
		parse = subject.split(",")
		location = nil;
		sublocation = nil;
		description = nil;

		parse.each do |item|
			id = item.split(":")[0]
			what = item.split(":")[1]
			id.downcase!
			if id.include?("what")
				description = what
			elsif id.include?("where")
				location =  what
				sublocation = what
			end
		end

		@info = [location, sublocation, description]
		return @info
	end

	#check if the email was sent to the right email address
	#adds a level of protection from users who might just post to the url in a malicious way
	def self.correctToEmail(email)
		return email == "3dcfe1f5df7214a766f7@cloudmailin.net"
	end
end
