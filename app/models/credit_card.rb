class CreditCard < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy
  belongs_to :bank, optional: true

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

  def limit=(value)
    if value.is_a?(String)
      # Converte formato brasileiro (1.234,56 ou 1234,56) para float válido no Ruby
      value = value.delete(".").tr(",", ".")
    end
    super(value)
  end

  def invoices
    transactions.order(due_date: :desc, created_at: :desc).group_by { |transaction| transaction.due_date&.beginning_of_month }.map do |month, month_transactions|
      {
        month: month,
        transactions: month_transactions,
        open: month_transactions.any?(&:pending?),
        paid: month_transactions.any? && month_transactions.all?(&:paid?)
      }
    end.sort_by { |invoice| invoice[:month] || Date.new(1900, 1, 1) }.reverse
  end

  def open_invoices
    ordered_invoices = invoices.select { |invoice| invoice[:open] }
    current_month = Date.current.beginning_of_month

    ordered_invoices.sort_by do |invoice|
      month = invoice[:month]
      if month == current_month
        [0, month]
      elsif month && month > current_month
        [1, month]
      else
        [2, month || Date.new(1900, 1, 1)]
      end
    end
  end

  def paid_invoices
    invoices.select { |invoice| invoice[:paid] }
  end

  def current_or_next_open_invoice
    open_invoices.first
  end
end
