class Conversation < ApplicationRecord
  belongs_to :user_one, class_name: "User", inverse_of: :started_conversations
  belongs_to :user_two, class_name: "User", inverse_of: :received_conversations
  has_many :messages, -> { order(:created_at, :id) }, dependent: :destroy

  validates :user_one_id, uniqueness: { scope: :user_two_id }
  validate :participants_must_differ

  def self.between(first_user, second_user)
    first_id, second_id = [ first_user.id, second_user.id ].sort
    find_or_create_by!(user_one_id: first_id, user_two_id: second_id)
  end

  def other_participant(user)
    user_one_id == user.id ? user_two : user_one
  end

  def includes?(user)
    user_one_id == user.id || user_two_id == user.id
  end

  private

  def participants_must_differ
    errors.add(:base, "A conversation requires two different users") if user_one_id == user_two_id
  end
end
