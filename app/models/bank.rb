class Bank < ApplicationRecord
    has_many :credit_cards, dependent: :nullify
    has_many :wallets, dependent: :nullify

    IMPORTERS = {
        "260" => TransactionImporters::Nubank,
        "077" => TransactionImporters::Inter
    }.freeze

    def importer_class
        IMPORTERS[code]
    end
end
