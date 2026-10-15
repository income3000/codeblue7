class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  enum :role, { member: "member", admin: "admin" }, default: :member

  has_many :incidents, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :started_conversations, class_name: "Conversation", foreign_key: :user_one_id, dependent: :destroy, inverse_of: :user_one
  has_many :received_conversations, class_name: "Conversation", foreign_key: :user_two_id, dependent: :destroy, inverse_of: :user_two

  validates :display_name, presence: true, length: { maximum: 80 }
  validates :bio, length: { maximum: 1000 }

  def conversations
    Conversation.where("user_one_id = :id OR user_two_id = :id", id: id)
  end
end
