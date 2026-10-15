class Incident < ApplicationRecord
  belongs_to :user
  belongs_to :official_record, optional: true
  has_many :comments, dependent: :destroy
  has_one_attached :picture

  validates :title, presence: true, length: { maximum: 160 }
  validates :description, presence: true, length: { maximum: 10_000 }
  validate :picture_is_an_image

  private

  def picture_is_an_image
    return unless picture.attached?

    unless picture.content_type&.start_with?("image/")
      errors.add(:picture, "must be an image")
    end
    errors.add(:picture, "must be smaller than 10 MB") if picture.byte_size > 10.megabytes
  end
end
