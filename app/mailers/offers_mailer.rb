class OffersMailer < ActionMailer::Base
	default :from => "offers@bytemap.com"

	def offer_mail(offer, mitlocation_id)
		potentialMails = Subscription.select("user_id").where(mitlocation_id: mitlocation_id)

		# send mail if location has at least 1 subscriber
		unless potentialMails.empty?
			#for each user that is subscribed to a building find the user instance and put the
			#user's email in a list, the mailer can use this list to send all the emails
			users_emails = potentialMails.collect { |subscription| User.find(subscription.user_id).get_text_address()}
			@offer = offer
			@mailing_list = mail(:to => users_emails,:subject => "")
			@mailing_list.deliver
		end
	end
end
