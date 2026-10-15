class OfficialRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_official_record, only: %i[ show edit update destroy ]
  before_action :authorize_owner!, only: %i[ edit update destroy ]

  SORT_OPTIONS = {
    "name" => "Name",
    "district" => "District",
    "badge_number" => "Badge number",
    "precinct" => "Precinct",
    "state" => "State",
    "city" => "City",
    "incident_names" => "Incidents named in",
    "case_number" => "Case number",
    "history" => "History",
    "decisions" => "Decisions",
    "professionalism_rating" => "Professionalism rating",
    "experience_rating" => "Overall experience rating",
    "created_at" => "Recently added"
  }.freeze

  def index
    @categories = OfficialRecord.categories
    @sort_options = SORT_OPTIONS
    @records = OfficialRecord.includes(:user)
    @records = @records.where(category: params[:category]) if OfficialRecord.categories.key?(params[:category])
    @records = @records.search_text(params[:q]) if params[:q].present?

    sort_column = SORT_OPTIONS.key?(params[:sort]) ? params[:sort] : "created_at"
    direction = params[:direction] == "asc" ? :asc : :desc
    if %w[professionalism_rating experience_rating].include?(sort_column)
      rating_column = sort_column == "professionalism_rating" ? :professionalism_rating : :experience_rating
      average_rating = Arel::Nodes::NamedFunction.new(
        "AVG",
        [ OfficialRecordReview.arel_table[rating_column] ]
      )
      unrated_value = direction == :asc ? 11 : 0
      rating_order = Arel::Nodes::NamedFunction.new(
        "COALESCE",
        [ average_rating, Arel::Nodes.build_quoted(unrated_value) ]
      )
      @records = @records.left_joins(:reviews)
        .group(OfficialRecord.arel_table[:id])
        .order(rating_order.public_send(direction), OfficialRecord.arel_table[:id].asc)
    else
      @records = @records.order(sort_column.to_sym => direction, id: :asc)
    end
    @rating_summaries = OfficialRecordReview.group(:official_record_id).pluck(
      :official_record_id,
      Arel.sql("AVG(professionalism_rating)"),
      Arel.sql("AVG(experience_rating)"),
      Arel.sql("COUNT(*)")
    ).index_by(&:first)
  end

  def show
    @reviews = @official_record.reviews.includes(:user).order(created_at: :desc)
    @review = current_user.official_record_reviews.find_or_initialize_by(official_record: @official_record)
    @average_professionalism_rating = @official_record.reviews.average(:professionalism_rating)&.round(1)
    @average_experience_rating = @official_record.reviews.average(:experience_rating)&.round(1)
  end

  def new
    @official_record = current_user.official_records.build(category: params[:category])
  end

  def create
    @official_record = current_user.official_records.build(official_record_params)
    if @official_record.save
      redirect_to @official_record, notice: "Directory entry added."
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @official_record.update(official_record_params)
      redirect_to @official_record, notice: "Directory entry updated."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @official_record.destroy!
    redirect_to official_records_path, notice: "Directory entry removed.", status: :see_other
  end

  private

  def set_official_record
    @official_record = OfficialRecord.find(params[:id])
  end

  def authorize_owner!
    return if @official_record.user == current_user || current_user.admin?

    redirect_to official_records_path, alert: "You cannot change this directory entry."
  end

  def official_record_params
    params.require(:official_record).permit(
      :category, :name, :district, :badge_number, :precinct, :state, :city,
      :incident_names, :case_number, :history, :decisions, :source_url
    )
  end
end
