class HomeController < ApplicationController
  def index
    @wallets = Current.user.wallets
    @credit_cards = Current.user.credit_cards.includes(:bank, :transactions).order(created_at: :desc)
    @credit_card_invoices = @credit_cards.to_h { |credit_card| [credit_card.id, credit_card.current_or_next_open_invoice] }
    @recent_transactions = Current.user.transactions.includes(:wallet, :credit_card).order(created_at: :desc).limit(5)
  end
end