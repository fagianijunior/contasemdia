class HomeController < ApplicationController
  def index
    @wallets = Current.user.wallets
    @recent_transactions = Current.user.transactions.includes(:wallet, :credit_card).order(created_at: :desc).limit(5)
  end
end