class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet
  belongs_to :credit_card
end
