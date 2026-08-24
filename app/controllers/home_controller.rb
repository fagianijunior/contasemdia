class HomeController < ApplicationController
  def index
    @wallets = Current.user.wallets
    @recent_transactions = Current.user.transactions.order(created_at: :desc).limit(5)
  end
end