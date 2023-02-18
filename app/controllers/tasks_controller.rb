# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    tasks = user.tasks

    render(json: tasks)
  end

  def show
    task = user.tasks.find(params[:id])

    render(json: task)
  end

  def create
    task = user.tasks.new(create_task_params.merge(status: :pending))

    if task.save
      render(status: :created, json: task)
    else
      render(
        status: :unprocessable_entity,
        json: {
          error: {
            message: 'Validation error',
            details: task.errors.full_messages
          }
        }
      )
    end
  end

  def complete
    task = user.tasks.find(params[:id])

    task.update!(status: :completed, completed_at: Time.current)

    if task.user.notification_preferences['task_completed'].present?
      if task.user.notification_preferences['task_completed'].include?('email')
        TaskMailer.with(task:).task_completed_notification.deliver_now
      end

      if task.user.notification_preferences['task_completed'].include?('sms')
        sms_client = FakeSmsClient.new(
          account_id: ENV.fetch('FAKE_SMS_ACCOUNT_ID'),
          auth_token: ENV.fetch('FAKE_SMS_AUTH_TOKEN')
        )
        sms_client.send_sms(
          from: ENV.fetch('FAKE_SMS_PHONE_NUMBER'),
          to: task.user.phone_number,
          body: "Task \"#{task.name}\" completed!"
        )
      end

      if task.user.notification_preferences['task_completed'].include?('telegram')
        telegram_client = FakeTelegramClient.new(auth_token: ENV.fetch('FAKE_TELEGRAM_AUTH_TOKEN'))
        telegram_client.send_message(
          chat_id: task.user.telegram_chat_id,
          text: "Task \"#{task.name}\" completed!"
        )
      end

      if task.user.notification_preferences['task_completed'].include?('whatsapp')
        whatsapp_client = FakeWhatsappClient.new(
          account_id: ENV.fetch('FAKE_WHATSAPP_ACCOUNT_ID'),
          auth_token: ENV.fetch('FAKE_WHATSAPP_AUTH_TOKEN')
        )
        whatsapp_client.send_message(
          from: "whatsapp:#{ENV.fetch('FAKE_WHATSAPP_PHONE_NUMBER')}",
          to: "whatsapp:#{task.user.phone_number}",
          body: "Task \"#{task.name}\" completed!"
        )
      end
    end

    render(json: task)
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def create_task_params
    params.require(:task).permit(:name)
  end
end
