class SessionsController < ApplicationController
	#if a session already exist send user to the home_path
	def new
	  if signed_in?
	    redirect_to home_path
		end
	end

	def create
	  user = User.find_by(email: params[:session][:email].downcase)
	  if user && user.authenticate(params[:session][:password])
	    # Sign the user in and redirect to the user's show page.
	    sign_in user
	    redirect_to root_url
	  else
	    # Create an error message and re-render the signin form    
		render 'new'
		flash.now[:error] = 'Unsuccessful Login: Invalid email/password combination'
	  end
	end

	def destroy
		sign_out
		redirect_to root_url
	end
end
