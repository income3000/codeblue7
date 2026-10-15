require "uri"

class OfficialRecord < ApplicationRecord
  belongs_to :user
  has_many :reviews, class_name: "OfficialRecordReview", dependent: :destroy

  enum :category, {
    police_officer: "police_officer",
    district_attorney: "district_attorney",
    judge: "judge"
  }, validate: true

  validates :category, presence: true
  validates :name, presence: true, length: { maximum: 160 }
  validates :city, presence: true, length: { maximum: 100 }
  validates :state, presence: true, length: { maximum: 100 }
  validates :district, :badge_number, :precinct, :case_number, length: { maximum: 100 }, allow_blank: true
  validates :source_url, length: { maximum: 2048 }, allow_blank: true
  validate :source_url_must_use_http

  scope :search_text, ->(query) {
    term = OfficialRecord.sanitize_sql_like(query.to_s.strip)
    if term.blank?
      all
    else
      pattern = "%#{term}%"
      where(
        "name LIKE :pattern OR city LIKE :pattern OR state LIKE :pattern OR district LIKE :pattern OR badge_number LIKE :pattern OR precinct LIKE :pattern OR incident_names LIKE :pattern OR case_number LIKE :pattern OR history LIKE :pattern OR decisions LIKE :pattern",
        pattern: pattern
      )
    end
  }

  def average_professionalism_rating
    reviews.average(:professionalism_rating)&.round(1)
  end

  def average_experience_rating
    reviews.average(:experience_rating)&.round(1)
  end

  private

  def source_url_must_use_http
    return if source_url.blank?

    uri = URI.parse(source_url)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:source_url, "must be a valid http or https URL")
  rescue URI::InvalidURIError
    errors.add(:source_url, "must be a valid http or https URL")
  end
end
