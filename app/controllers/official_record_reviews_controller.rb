class OfficialRecordReviewsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_official_record
  before_action :set_review, only: %i[ update destroy ]
  before_action :authorize_review_owner!, only: %i[ update destroy ]

  def create
    @review = @official_record.reviews.find_or_initialize_by(user: current_user)
    @review.assign_attributes(review_params)

    if @review.save
      redirect_to @official_record, notice: "Your rating was saved."
    else
      redirect_to @official_record, alert: @review.errors.full_messages.to_sentence
    end
  end

  def update
    if @review.update(review_params)
      redirect_to @official_record, notice: "Your rating was updated."
    else
      redirect_to @official_record, alert: @review.errors.full_messages.to_sentence
    end
  end

  def destroy
    @review.destroy!
    redirect_to @official_record, notice: "Your rating was removed.", status: :see_other
  end

  private

  def set_official_record
    @official_record = OfficialRecord.find(params[:official_record_id])
  end

  def set_review
    @review = @official_record.reviews.find(params[:id])
  end

  def authorize_review_owner!
    return if @review.user == current_user || current_user.admin?

    redirect_to @official_record, alert: "You can only change your own rating."
  end

  def review_params
    params.require(:official_record_review).permit(:professionalism_rating, :experience_rating, :comment)
  end
end
