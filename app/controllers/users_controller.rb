class UsersController < ApplicationController
  require 'rest_client'
  require 'json'
  before_action :set_user, only: [:edit, :update, :destroy]
  before_action :signed_in_user, only: [:edit, :update]
  before_action :correct_user, only: [:edit, :update]

  #sources: railscasts 274, and http://ruby.railstutorial.org/chapters/sign-in-sign-out#top
  # GET /users/new
  def new
    @user = User.new
  end

  def exists
    signedin = signed_in?
    respond_to do |format|
      format.html
      format.json {render json: signedin }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.email =@user.email.downcase
    #query mit people search to confirm valid mit email
    @info = @user.get_MIT_people_email()
    #call a model method to translate the provider picked by the user
    #to the provider gateway address. This gives free texting in the form of an email
    @user.provider = @user.provider_to_email(user_params[:provider])

    respond_to do |format|
      if @info.include?(@user.email)
        if @user.save
          sign_in @user
          format.html { redirect_to root_url, notice: 'User was successfully created.' }
          format.json { render action: 'show', status: :created, location: @user }
        else
          format.html { render action: 'new'}
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else

        format.html { flash[:notice] = 'Not a valid MIT email.'
                      render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end    
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      params[:user][:provider] = @user.provider_to_email(user_params[:provider])
      if @user.update(user_params)
        format.html { redirect_to root_url, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      sign_out
      format.html { redirect_to root_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # verifies that people can only access their own information and edit their profile
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_url, notice: "Can't edit that page" unless current_user?(@user)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:name, :email,:phoneNumber, :provider, :password,:password_confirmation)
    end

    #verify that the user is signed in before allowing offering creation
    def signed_in_user
      redirect_to signin_url, notice: "Please sign in." unless signed_in?
    end
end
