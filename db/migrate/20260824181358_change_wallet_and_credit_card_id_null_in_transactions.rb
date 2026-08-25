class ChangeWalletAndCreditCardIdNullInTransactions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :transactions, :wallet_id, true
    change_column_null :transactions, :credit_card_id, true
  end
end
