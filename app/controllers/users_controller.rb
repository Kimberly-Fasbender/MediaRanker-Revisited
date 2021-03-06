class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def show
    @user = User.find_by(id: params[:id])
    render_404 unless @user
  end

  def create
    auth_hash = request.env["omniauth.auth"]
    user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])

    if user
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.name}"
    else
      user = User.build_from_github(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.name} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        redirect_to root_path, status: :bad_request
        return
      end
    end

    session[:user_id] = user.id
    redirect_to root_path
    return
  end

  def destroy
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
