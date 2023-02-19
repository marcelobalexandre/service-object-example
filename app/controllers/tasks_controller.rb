# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    tasks = user.tasks

    serialized_tasks = tasks.map do |task|
      {
        'id' => task.id,
        'userId' => user.id,
        'status' => task.status,
        'name' => task.name,
        'createdAt' => task.created_at,
        'completedAt' => task.completed_at
      }
    end

    render(json: serialized_tasks)
  end

  def show
    task = user.tasks.find(params[:id])

    serializer_task = {
      'id' => task.id,
      'userId' => user.id,
      'status' => task.status,
      'name' => task.name,
      'createdAt' => task.created_at,
      'completedAt' => task.completed_at
    }

    render(json: serializer_task)
  end

  def create
    task = user.tasks.new(create_task_params.merge(status: :pending))

    if task.save
      serializer_task = {
        'id' => task.id,
        'userId' => user.id,
        'status' => task.status,
        'name' => task.name,
        'createdAt' => task.created_at,
        'completedAt' => task.completed_at
      }

      render(status: :created, json: serializer_task)
    else
      serializer_error = {
        'error' => {
          'message' => 'Validation error',
          'details' => task.errors.full_messages
        }
      }

      render(status: :unprocessable_entity, json: serializer_error)
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

    serialized_task = {
      'id' => task.id,
      'userId' => user.id,
      'status' => task.status,
      'name' => task.name,
      'createdAt' => task.created_at,
      'completedAt' => task.completed_at
    }

    render(json: serialized_task)
  end

  private

  def user
    @user ||= User.find(params[:user_id])
  end

  def create_task_params
    params.require(:task).permit(:name)
  end
end
