class CreditCard < ApplicationRecord
  belongs_to :user
  has_many :transactions, dependent: :destroy

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
end
