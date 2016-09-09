module ApplicationHelper
	def event_time_format(time)
	  now = Time.now
	  if now - time > 7.days
	    'on '+ l(time, :format => :short)
	  else
	    distance_of_time_in_words(time, now, true) + ' ago'
	  end
	end
end
