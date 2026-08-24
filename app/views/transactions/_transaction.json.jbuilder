json.extract! transaction, :id, :user_id, :wallet_id, :credit_card_id, :title, :amount, :transaction_type, :status, :due_date, :payment_date, :created_at, :updated_at
json.url transaction_url(transaction, format: :json)
