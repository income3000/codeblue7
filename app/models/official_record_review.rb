class OfficialRecordReview < ApplicationRecord
  belongs_to :official_record, class_name: "OfficialRecord", inverse_of: :reviews
  belongs_to :user

  validates :professionalism_rating, :experience_rating,
    numericality: { only_integer: true, in: 1..10 }
  validates :comment, length: { maximum: 2_000 }, allow_blank: true
  validates :user_id, uniqueness: { scope: :official_record_id }
end
