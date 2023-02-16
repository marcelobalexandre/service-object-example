# frozen_string_literal: true

class Task < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending completed] }
  validates :name, presence: true
end
