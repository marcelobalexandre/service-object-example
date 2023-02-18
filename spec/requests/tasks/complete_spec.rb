# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tasks' do
  describe 'PATCH /users/:user_id/tasks/:task_id/complete' do
    let(:task) { create(:task) }

    context 'when task exists' do
      it 'responds with 200 (:ok)' do
        patch("/users/#{task.user.id}/tasks/#{task.id}/complete")

        expect(response).to have_http_status(:ok)
      end

      it 'marks task as completed' do
        expect { patch("/users/#{task.user.id}/tasks/#{task.id}/complete") }
          .to change { task.reload.completed? }.from(false).to(true)
          .and change { task.reload.completed_at }.from(nil).to(be_present)
      end

      it 'returns updated task in the response' do
        patch("/users/#{task.user.id}/tasks/#{task.id}/complete")

        expect(JSON.parse(response.body)).to eq(task.reload.as_json)
      end
    end

    context 'when task does not exist' do
      it 'responds with 404 (:not_found)' do
        patch("/users/#{task.user.id}/tasks/0/complete")

        expect(response).to have_http_status(:not_found)
      end

      it 'returns a error details in the response' do
        patch("/users/#{task.user.id}/tasks/0/complete")

        expect(JSON.parse(response.body)).to include('error' => { 'message' => 'Not found' })
      end
    end

    context 'when user does not exist' do
      it 'responds with 404 (:not_found)' do
        patch('/users/0/tasks/0/complete')

        expect(response).to have_http_status(:not_found)
      end

      it 'returns a error details in the response' do
        patch('/users/0/tasks/0/complete')

        expect(JSON.parse(response.body)).to include('error' => { 'message' => 'Not found' })
      end
    end
  end
end
