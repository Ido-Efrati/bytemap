class ActivitiesController < ApplicationController

  #public_activity gem-generated model link to get activity feed 
  def index
  	@activities = PublicActivity::Activity.order("created_at desc")
  end
end
