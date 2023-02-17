# frozen_string_literal: true

user = User.create!(
  name: 'Phoebe Buffay',
  email: 'phoebe@buffay.com',
  phone_number: '+1234567890',
  telegram_chat_id: 'telegram-chat-id'
)
user.tasks.create!(name: 'Record Smelly Cat', status: :pending)
