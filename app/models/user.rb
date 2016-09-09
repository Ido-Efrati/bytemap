class User < ActiveRecord::Base
    validates :email, presence: true, uniqueness: true
    has_many :offerings
    has_secure_password

    validates :password, length: {minimum: 6}, :allow_blank => true
    validates :phoneNumber,length: {is: 10}, uniqueness: true, presence: true, if: lambda{ |record| record.provider.present? }
	validates :provider, presence: true, if: lambda{ |record| record.phoneNumber.present? }
	before_create :create_remember_token

	#initiates email with password resend link
    def send_password_reset
    	generate_reset_token(:password_reset_token)
    	self.password_reset_sent_at = Time.zone.now
    	save!(validate: false)
    	UserMailer.password_reset(self).deliver
    end

	def User.new_remember_token
	  SecureRandom.urlsafe_base64
	end

	#used to encrypt passwords to create password_digest
	def User.encrypt(token)
	  Digest::SHA1.hexdigest(token.to_s)
	end

	#creates a new token for a password reset
    def generate_reset_token(column)
	  begin
	    self[column] = SecureRandom.urlsafe_base64
	  end while User.exists?(column => self[column])
	end

	#converts phone number to email address based on provider to enable free texting via email
	def provider_to_email(providerName)		 
		if providerName.eql? "T-Mobile"
			return "@tmomail.net"
		elsif providerName.eql? "AT&T"
			return "@txt.att.net"
		elsif providerName.eql? "Verizon"
			return "@vtext.com"
		else
			return nil
		end
	end

	#query mit people search to confirm valid mit email
	def get_MIT_people_email()
    	kerberos = self.email.split('@')[0]
    	info = RestClient.get 'http://web.mit.edu/bin/cgicso?', {:params => {:options => "general", :query => kerberos, :output =>'json'}}
    	return info.downcase
	end

	#checks if we have all the needed information to create a subscription
	def can_subscribe?()
    	return !(self.phoneNumber.nil?)
	end

	#email address that can be used to send text message
	def get_text_address()
		email = self.phoneNumber.to_s + self.provider
		return email
    end

    #get the userid and if the user can subscribe to a location
    def self.get_subscriptionInfo(current_user)
    	if current_user.nil?
    		info = [-1, false]
    		return info
    	else
    		info = [current_user.id, current_user.can_subscribe?()]
    		return info
    	end
    end

	private
		#the remember token is used to store a session hash
		def create_remember_token
	      self.remember_token = User.encrypt(User.new_remember_token)
	    end
end
