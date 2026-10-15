class Message < ApplicationRecord
  belongs_to :conversation, touch: true
  belongs_to :user

  validates :body, presence: true, length: { maximum: 5_000 }
  validate :author_must_be_a_participant

  private

  def author_must_be_a_participant
    return if conversation&.includes?(user)

    errors.add(:user, "must belong to this conversation")
  end
end
