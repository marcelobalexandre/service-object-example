# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    tasks = Task.where(user_id: params[:user_id])

    render(json: tasks)
  end

  def show
    task = Task.find_by(id: params[:id], user_id: params[:user_id])

    render(json: task)
  end

  def create
    task = Task.new(create_task_params.merge(user_id: params[:user_id], status: :pending))

    task.save!

    render(status: :created, json: task)
  end

  def complete
    task = Task.find_by(id: params[:id], user_id: params[:user_id])

    task.update!(status: :completed, completed_at: Time.current)

    TaskMailer.with(task:).task_completed_notification.deliver_later

    render(json: task)
  end

  private

  def create_task_params
    params.require(:task).permit(:user_id, :name)
  end
end
