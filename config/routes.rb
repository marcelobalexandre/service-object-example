# frozen_string_literal: true

Rails.application.routes.draw do
  resources :users, only: %i[create] do
    resources :tasks, only: %i[index show create] do
      patch :complete, on: :member
    end
  end
end
