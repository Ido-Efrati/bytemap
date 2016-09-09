class SubscriptionsController < ApplicationController
  before_action :set_subscription, only: [:destroy]

  #source: railscasts 206
  # GET /subscriptions/new
  def new
    @subscription = Subscription.new
  end


  # POST /subscriptions
  # POST /subscriptions.json
  def create
    @subscription = Subscription.new(subscription_params)
    respond_to do |format|
      if @subscription.save
        format.html { redirect_to root_url, notice: 'Subscription was successfully created.' }
        format.json { render action: 'show', status: :created, location: @subscription }
      else
        format.html { render action: 'new' }
        format.json { render json: @subscription.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /subscriptions/1/destroy
  # DELETE /subscriptions/1/destroy.json
  def destroy
    @subscription.destroy
    respond_to do |format|
      format.html { redirect_to root_url}
      format.json { head :no_content }
    end
  end

  #ajax needs to not have a redirect
  def destroyViaAjax
    @subscription = Subscription.find(params[:id])
    @subscription.destroy
    respond_to do |format|
      format.html { render :template => 'locations/index'}
      format.json { head :no_content }
    end
  end


  #GET /subscriptions/exists
  #@param mitlocation_id from whereismit custom id
  #check if a subdcription exists, if it does, return the id, otherwise return -1
  def exists
    subscriptionId = Subscription.getSubscribedId(params[:mitlocation_id], params[:user_id])
    respond_to do |format|
      format.html
      format.json {render json: subscriptionId}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subscription
      @subscription = Subscription.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def subscription_params
      params.require(:subscription).permit(:mitlocation_id, :user_id)
    end
end
