class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_conversation

  def create
    unless @conversation.includes?(current_user)
      return redirect_to conversations_path, alert: "That conversation is private."
    end

    @message = @conversation.messages.build(message_params)
    @message.user = current_user
    if @message.save
      redirect_to conversation_path(@conversation, anchor: "messages")
    else
      redirect_to conversation_path(@conversation), alert: @message.errors.full_messages.to_sentence
    end
  end

  private

  def set_conversation
    @conversation = Conversation.find(params[:conversation_id])
  end

  def message_params
    params.require(:message).permit(:body)
  end
end
