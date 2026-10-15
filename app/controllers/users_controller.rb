class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :authorize_profile!, only: %i[ edit update ]

  def show
  end

  def edit
  end

  def update
    if @user.update(profile_params)
      redirect_to @user, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def authorize_profile!
    return if @user == current_user || current_user.admin?

    redirect_to root_path, alert: "You can only edit your own profile."
  end

  def profile_params
    params.require(:user).permit(:display_name, :bio)
  end
end
