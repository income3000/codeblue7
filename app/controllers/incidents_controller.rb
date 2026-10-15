class IncidentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_incident, only: %i[ show edit update destroy ]
  before_action :authorize_incident!, only: %i[ edit update destroy ]

  def index
    @incidents = Incident.includes(:user, :comments).order(created_at: :desc)
  end

  def show
    @comments = @incident.comments.includes(:user).order(:created_at)
    @comment = @incident.comments.build
  end

  def new
    @incident = current_user.incidents.build
  end

  def create
    @incident = current_user.incidents.build(incident_params)
    if @incident.save
      redirect_to @incident, notice: "Incident posted."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @incident.update(incident_params)
      redirect_to @incident, notice: "Incident updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @incident.destroy!
    redirect_to incidents_path, notice: "Incident removed.", status: :see_other
  end

  private

  def set_incident
    @incident = Incident.find(params[:id])
  end

  def authorize_incident!
    return if @incident.user == current_user || current_user.admin?

    redirect_to incidents_path, alert: "You cannot change this incident."
  end

  def incident_params
    params.require(:incident).permit(:title, :description, :location, :occurred_at, :picture)
  end
end
