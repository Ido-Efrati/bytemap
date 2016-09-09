class OfferingsController < ApplicationController
  before_action :signed_in_user, only: [:create, :update, :new]
  before_action :set_offering, only: [:edit, :update, :destroy]


  # POST /offerings
  # POST /offerings.json
  # @params location - custom id gotten from whereismit
  # @params sublocation - text descriptor of location
  # @params description - description of food offered

  #handles posting to an existing location
  def create
    #assign attributes passed from the create form window
    @offering = Offering.new
    @offering.owner_id = @current_user.id
    @offering.sub_location = params[:offering][:sub_location]
    @offering.description = params[:offering][:description]
    @offering.numDeleteVotes = 0

    location = params[:offering][:location]

    #if we already have an entry for our location, get the id and assign it to offering
    if Location.exists?(:customid => location)
      @offering.location_id = Location.find_by_customid(location).id
      respond_to do |format|
        if @offering.save
          @offering.create_activity :create, owner: current_user
          format.html { redirect_to root_url, notice: 'Byte was successfully created.' }
          format.json { render action: 'show', status: :created, location: @offering }
          OffersMailer.offer_mail(@offering, location)
        else
          format.html { render action: 'new' }
          format.json { render json: @offering.errors, status: :unprocessable_entity }
        end
      end

    # concurrency workaround: another user deleted the last offering at this location so the 
    # location no longer exists, but this user tried to create a new offering at this location 
    # because this user's page has not refreshed yet
    else
      respond_to do |format|
        if (params[:offering][:from_email]).nil?
          format.html {redirect_to root_url, alert: "Sorry, this location no longer exists because it has been deleted by another user."}
        else
          format.html {render :text => 'success', :status => 200}
        end
      end
    end
  end

  # PATCH/PUT /offerings/1
  # PATCH/PUT /offerings/1.json
  def update
    respond_to do |format|
      if @offering.update(offering_params)
        format.html { redirect_to root_url, notice: 'Byte was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @offering.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /offerings/1
  # DELETE /offerings/1.json

  def destroy
    
    # variables to be sent to js.erb
    @offering_exists = false
    @emptylocation = false
    @alreadyvoted = false

    # offering no longer exists due to other users deleting it before this user's page refreshed
    if not defined? @offering
      @offering_exists = false

    # offering exists
    else
      @offering_exists = true
      #cast a vote to destroy the offering
      @offering.vote_to_destroy(session)

      # destroy offering if enough votes cast
      if @offering.sufficient_votes?

        # destroys offering and/or location if empty, returns true if location was destroyed 
        # as a result of this offering being destroyed
        @emptylocation = @offering.custom_destroy()
      end
      @alreadyvoted = (session[:votes].index(@offering.id) >= 0)
    end
    respond_to do |format|  
      format.js {}
    end
  end


  private

    def signed_in_user
        redirect_to root_url, alert: "Action Unsuccessful, please sign in." unless signed_in?
    end
    # Use callbacks to share common setup or constraints between actions.

    def set_offering
      if Offering.exists?(:id => params[:id])
        @offering = Offering.find(params[:id])
      end
    end


    # Never trust parameters from the scary internet, only allow the white list through.
    def offering_params
      params.permit(:offering, :location, :sub_location, :description)
    end
end
