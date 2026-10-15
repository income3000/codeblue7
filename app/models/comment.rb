class Comment < ApplicationRecord
  belongs_to :incident
  belongs_to :user

  validates :body, presence: true, length: { maximum: 2_000 }
end
