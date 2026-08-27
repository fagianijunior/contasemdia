class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ show edit update destroy ]

  def index
    @wallets = Current.user.wallets.order(created_at: :desc)
  end

  def show
  end

  def new
    @wallet = Current.user.wallets.new
    @banks = Bank.order(:name)
  end

  def edit
    @banks = Bank.order(:name)
  end

  def create
    @wallet = Current.user.wallets.new(wallet_params.except(:csv_file))
    csv_file = wallet_params[:csv_file]

    if @wallet.save
      if csv_file.present?
        importer_class = @wallet.bank&.importer_class

        if importer_class
          begin
            count = importer_class.new(@wallet, csv_file.path).import
            flash[:notice] = "Carteira criada com sucesso e #{count} transações importadas."
          rescue StandardError => e
            logger.error "Erro ao importar CSV: #{e.message}\n#{e.backtrace.join("\n")}"
            flash[:alert] = "Carteira criada, mas houve um erro ao processar o CSV. Verifique o arquivo."
          end
        else
          bank_name = @wallet.bank&.name || "selecionado"
          flash[:alert] = "Carteira criada, mas a importação de CSV ainda não é suportada para o banco #{bank_name}."
        end
      else
        flash[:notice] = "Carteira criada com sucesso."
      end

      redirect_to wallets_path
    else
      @banks = Bank.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @wallet.update(wallet_params)
      redirect_to @wallet, notice: "Carteira atualizada com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @wallet.destroy!
    redirect_to wallets_path, notice: "Carteira removida com sucesso.", status: :see_other
  end

  private

  def set_wallet
    @wallet = Current.user.wallets.find(params.expect(:id))
  end

  def wallet_params
    params.expect(wallet: [ :name, :wallet_type, :bank_id, :balance, :csv_file ])
  end
end
