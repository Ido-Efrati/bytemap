class IncomingemailsController < ApplicationController
  require 'mail'
  require 'rest_client'
  require 'json'
  skip_before_filter :verify_authenticity_token

  def create
    #Get the subject line and parse for location
    @information = Incomingemail.parseEmail(params[:headers]['Subject'])
    @location = @information[0]
    @to = params[:envelope][:to]

    #if the location was able to be parsed create the location. 
    if !@location.nil? && Incomingemail.correctToEmail(@to)
      response = RestClient.get 'http://whereis.mit.edu/search', {:params => {:type => 'query', :q => @location, :output =>'json'}}
      response = JSON.parse(response)[0]

      #if the location returns a valid mit location
      if !response.nil?
        #creating a new location or getting the current location
        #returns an array [location.id, location.customid]
        @location = Location.create_from_whereis(response)
        #create the offering, should probably do a redirect to preserve rails security
        @offering = Offering.new
        @offering.sub_location = @information[1]
        @offering.description = @information[2]
        @offering.location_id = @location[0]
        if @offering.save
          OffersMailer.offer_mail(@offering, @location[1])
        end
      end
    end

    respond_to do |format|
      format.html{render :text => 'success', :status => 200}
      format.json{}
    end
  end
end