json.extract! wallet, :id, :user_id, :name, :wallet_type, :balance, :created_at, :updated_at
json.url wallet_url(wallet, format: :json)
