module Admin
  class UsersController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin!

    def index
      @users = User.order(:display_name)
    end

    def update
      user = User.find(params[:id])
      if user == current_user
        return redirect_to admin_users_path, alert: "You cannot change your own administrator role."
      end

      role = params.require(:user).permit(:role).fetch(:role)
      unless User.roles.key?(role)
        return redirect_to admin_users_path, alert: "Choose a valid account role."
      end

      user.update!(role: role)
      redirect_to admin_users_path, notice: "Account role updated."
    rescue ActiveRecord::RecordInvalid, ActionController::ParameterMissing => error
      redirect_to admin_users_path, alert: error.message
    end

    private

    def require_admin!
      return if current_user.admin?

      redirect_to root_path, alert: "Administrator access is required."
    end
  end
end
