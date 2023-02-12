# frozen_string_literal: true

class TasksController < ApplicationController
  def index
    render(json: Task.all)
  end

  def show
    task = Task.find(params[:id])

    render(json: task)
  end

  def create
    task = Task.new(create_task_params.merge(status: :pending))

    task.save!

    render(status: :created, json: task)
  end

  def complete
    task = Task.find(params[:id])

    task.update!(status: :completed, completed_at: Time.current)

    render(json: task)
  end

  private

  def create_task_params
    params.require(:task).permit(:name)
  end
end
