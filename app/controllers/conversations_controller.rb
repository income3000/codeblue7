class ConversationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation, only: :show
  before_action :authorize_participant!, only: :show

  def index
    @conversations = current_user.conversations.includes(:user_one, :user_two, :messages).order(updated_at: :desc)
    @users = User.where.not(id: current_user.id).order(:display_name)
  end

  def create
    recipient = User.find(params.require(:recipient_id))
    if recipient == current_user
      return redirect_to conversations_path, alert: "Choose another user to start a conversation."
    end

    conversation = Conversation.between(current_user, recipient)
    redirect_to conversation_path(conversation)
  rescue ActiveRecord::RecordInvalid => error
    redirect_to conversations_path, alert: error.record.errors.full_messages.to_sentence
  end

  def show
    @messages = @conversation.messages.includes(:user)
    @message = @conversation.messages.build
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:id])
  end

  def authorize_participant!
    return if @conversation.includes?(current_user)

    redirect_to conversations_path, alert: "That conversation is private."
  end
end
