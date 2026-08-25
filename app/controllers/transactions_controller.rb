class TransactionsController < ApplicationController
  before_action :set_transaction, only: %i[ show edit update destroy ]

  def index
    @transactions = Current.user.transactions.includes(:wallet, :credit_card).order(due_date: :desc, created_at: :desc)

    # Filtros
    @transactions = @transactions.where(transaction_type: params[:type]) if params[:type].present?
    @transactions = @transactions.where(status: params[:status]) if params[:status].present?
    @transactions = @transactions.where(wallet_id: params[:wallet_id]) if params[:wallet_id].present?
    @transactions = @transactions.where(credit_card_id: params[:credit_card_id]) if params[:credit_card_id].present?
    @transactions = @transactions.where("title ILIKE ?", "%#{params[:query]}%") if params[:query].present?
  end

  def show
  end

  def new
    @transaction = Current.user.transactions.new
  end

  def edit
  end

  def create
    if params[:csv_import].present?
      handle_csv_import
      return
    end

    @transaction = Current.user.transactions.new(transaction_params)

    if @transaction.save
      handle_installments if @transaction.total_installments.to_i > 1
      redirect_to transactions_path, notice: "Lançamento criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @transaction.update(transaction_params)
      handle_installments if params[:split_installments].present? && @transaction.total_installments.to_i > 1
      redirect_to @transaction, notice: "Lançamento atualizado com sucesso.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction.destroy!
    redirect_to transactions_path, notice: "Lançamento removido com sucesso.", status: :see_other
  end

  private

  def set_transaction
    @transaction = Current.user.transactions.find(params.expect(:id))
  end

  def handle_installments
    total = @transaction.total_installments.to_i
    base_date = @transaction.due_date || Date.today
    
    # Atualiza a transação atual para ser a parcela 1
    @transaction.update(installment: 1, amount: @transaction.amount / total)
    
    # Cria as demais parcelas
    (2..total).each do |i|
      new_transaction = @transaction.dup
      new_transaction.installment = i
      new_transaction.due_date = base_date + (i - 1).months
      new_transaction.payment_date = nil
      new_transaction.status = "pending"
      new_transaction.fingerprint = nil # Evita conflitos de fingerprint nas parcelas
      new_transaction.save!
    end
  end

  def handle_csv_import
    csv_file = params[:csv_file]
    bank = params[:import_bank]
    target_type = params[:import_target_type] # 'wallet' ou 'credit_card'
    target_id = params[:import_target_id]

    if csv_file.blank? || target_id.blank? || bank.blank?
      flash[:alert] = "Selecione o arquivo, o banco e a conta de destino para importar."
      redirect_to new_transaction_path
      return
    end

    begin
      target = if target_type == "wallet"
                 Current.user.wallets.find(target_id)
               else
                 Current.user.credit_cards.find(target_id)
               end

      importer_class = case [bank, target_type]
                       when ["Nubank", "wallet"] then TransactionImporters::Nubank
                       when ["Inter", "wallet"] then TransactionImporters::Inter
                       when ["Nubank", "credit_card"] then TransactionImporters::NubankCreditCard
                       when ["Inter", "credit_card"] then TransactionImporters::InterCreditCard
                       else nil
                       end

      if importer_class
        count = importer_class.new(target, csv_file.path).import
        flash[:notice] = "#{count} transações importadas com sucesso!"
      else
        flash[:alert] = "Importação não suportada para a combinação de Banco e Tipo selecionada."
      end
    rescue StandardError => e
      logger.error "Erro na importação de CSV: #{e.message}"
      flash[:alert] = "Ocorreu um erro ao importar o arquivo: #{e.message}"
    end

    redirect_to transactions_path
  end

  def transaction_params
    params.expect(transaction: [
      :wallet_id, :credit_card_id, :title, :category, :amount,
      :transaction_type, :status, :due_date, :payment_date,
      :installment, :total_installments
    ])
  end
end
