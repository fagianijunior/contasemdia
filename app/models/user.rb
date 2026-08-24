class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  # Recursos financeiros
  has_many :wallets, dependent: :destroy
  has_many :credit_cards, dependent: :destroy
  has_many :transactions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end