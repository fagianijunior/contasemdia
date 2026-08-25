class Wallet < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

  enum :wallet_type, { checking: 0, savings: 1, cash: 2, investment: 3, other: 4 }

  WALLET_TYPE_LABELS = {
    "checking" => "Conta Corrente",
    "savings" => "Poupança",
    "cash" => "Dinheiro",
    "investment" => "Investimento",
    "other" => "Outro"
  }.freeze

  BANKS = [
    "Inter",
    "Nubank",
    "Caixa Econômica",
    "Banco do Brasil",
    "C6 Bank",
    "Itaú",
    "Bradesco",
    "Santander",
    "Outro"
  ].freeze

  def balance=(value)
    if value.is_a?(String)
      # Converte formato brasileiro (1.234,56 ou 1234,56) para float válido no Ruby
      value = value.delete(".").tr(",", ".")
    end
    super(value)
  end

  def current_balance
    incomes = transactions.income.paid.sum(:amount)
    expenses = transactions.expense.paid.sum(:amount)
    
    (balance || 0) + incomes - expenses
  end
end
