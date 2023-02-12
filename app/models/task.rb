# frozen_string_literal: true

class Task < ApplicationRecord
  validates :status, presence: true, inclusion: { in: %w[pending completed] }
  validates :name, presence: true
end
