# frozen_string_literal: true

class UsersController < ApplicationController
  def create
    user = User.new(create_user_params)

    if user.save
      render(status: :created, json: user)
    else
      render(
        status: :unprocessable_entity,
        json: {
          error: {
            message: 'Validation error',
            details: user.errors.full_messages
          }
        }
      )
    end
  end

  private

  def create_user_params
    params.require(:user).permit(:name, :email, :phone_number, :telegram_chat_id, notification_preferences: {})
  end
end
