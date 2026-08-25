class Transaction < ApplicationRecord
  belongs_to :user
  belongs_to :wallet, optional: true
  belongs_to :credit_card, optional: true

  enum :transaction_type, { expense: 0, income: 1 }
  enum :status, { pending: 0, paid: 1 }

  TRANSACTION_TYPE_LABELS = {
    "expense" => "Despesa",
    "income" => "Receita"
  }.freeze

  STATUS_LABELS = {
    "pending" => "Pendente",
    "paid" => "Pago"
  }.freeze

  def amount=(value)
    if value.is_a?(String)
      # Converte formato brasileiro (1.234,56 ou 1234,56) para float válido no Ruby
      value = value.delete(".").tr(",", ".")
    end
    super(value)
  end
end
