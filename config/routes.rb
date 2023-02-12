# frozen_string_literal: true

Rails.application.routes.draw do
  resources :tasks, only: %i[index show create] do
    patch :complete, on: :member
  end
end
