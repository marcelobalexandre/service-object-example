# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user = User.new(create_user_params)

    user.save!

    render(status: :created, json: user)
  end

  private

  def create_user_params
    params.require(:user).permit(:name, :email, :phone_number, :telegram_chat_id, notification_preferences: {})
  end
end
