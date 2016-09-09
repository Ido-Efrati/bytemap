class PasswordResetsController < ApplicationController

  #initialized password reset process by sending an email to the user
  def create
  	user = User.find_by_email(params[:email])
  	user.send_password_reset if User.exists?(user)
  	redirect_to root_url, :notice => "Email sent with password reset instructions"
  end

  def edit
  	@user = User.find_by_password_reset_token!(params[:id])
  end


  def update
  	@user = User.find_by_password_reset_token!(params[:id])
  	#emailed reset link expires after 2 hours, check if still valid
  	if @user.password_reset_sent_at < 2.hours.ago
  		redirect_to new_password_reset_path, :alert => "Password reset link expired, please re-send"
  	#updates password_digest in database
  	elsif @user.update_attributes(:password => params[:user][:password], :password_confirmation => params[:user][:password_confirmation])
        redirect_to root_url, notice: 'User was successfully updated.'
  	else
  		render :edit
  	end
  end
end
