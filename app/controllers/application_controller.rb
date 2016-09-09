class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include PublicActivity::StoreController
  protect_from_forgery with: :exception
  before_action :check_voting_cookie
  include SessionsHelper	

  # if client does not have a voting cookie, initializes the voting cookie
  def check_voting_cookie
    unless session[:votes]
      session[:votes] = []
    end
  end  
end
