# frozen_string_literal: true

class User < ApplicationRecord
  has_many :tasks, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :phone_number, presence: true, uniqueness: true
  validates :telegram_chat_id, presence: true, uniqueness: true
end
