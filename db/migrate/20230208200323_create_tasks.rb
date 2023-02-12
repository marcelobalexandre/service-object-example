# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :tasks do |t|
      t.string :status, null: false
      t.string :name, null: false
      t.timestamp :completed_at

      t.timestamps
    end
  end
end
