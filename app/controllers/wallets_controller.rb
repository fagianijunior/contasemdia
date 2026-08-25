class WalletsController < ApplicationController
  before_action :set_wallet, only: %i[ show edit update destroy ]

  def index
    @wallets = Current.user.wallets.order(created_at: :desc)
  end

  def show
  end

  def new
    @wallet = Current.user.wallets.new
  end

  def edit
  end

  def create
    @wallet = Current.user.wallets.new(wallet_params.except(:csv_file))
    csv_file = wallet_params[:csv_file]

    if @wallet.save
      if csv_file.present?
        importer_class = case @wallet.bank
                         when "Nubank"
                           TransactionImporters::Nubank
                         when "Inter"
                           TransactionImporters::Inter
                         else
                           nil
                         end

        if importer_class
          begin
            count = importer_class.new(@wallet, csv_file.path).import
            flash[:notice] = "Carteira criada com sucesso e #{count} transações importadas."
          rescue StandardError => e
            logger.error "Erro ao importar CSV: #{e.message}"
            flash[:notice] = "Carteira criada, mas houve um erro ao importar o arquivo CSV. Verifique se o formato está correto para o banco selecionado."
          end
        else
          flash[:notice] = "Carteira criada. Importação de CSV não suportada para o banco #{@wallet.bank} ainda."
        end
      else
        flash[:notice] = "Carteira criada com sucesso."
      end
      redirect_to wallets_path
    else
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
    params.expect(wallet: [ :name, :wallet_type, :bank, :balance, :csv_file ])
  end
end
