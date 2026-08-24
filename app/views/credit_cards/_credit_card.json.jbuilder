json.extract! credit_card, :id, :user_id, :name, :limit, :closing_day, :due_day, :created_at, :updated_at
json.url credit_card_url(credit_card, format: :json)
