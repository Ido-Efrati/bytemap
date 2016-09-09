class UserMailer < ActionMailer::Base
  default from: "users@bytemap.com"
  def password_reset(user)
  	@user = user
  	mail :to => user.email, :subject => "Bytemap: Password Reset" 
  end
end
