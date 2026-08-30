module TransactionImporters
  class NubankCreditCard < Base
    protected

    def csv_options
      { headers: true, col_sep: ",", quote_char: '"' }
    end

    def skip_row?(row)
      row["date"].blank? || row["title"] == "Pagamento recebido"
    end

    def parse_row(row)
      # Formato: date,title,amount
      # Ex: 2024-04-24,Pg *Leroy Merlin Leroy,"183,15"
      # Ex: 2024-04-16,Fix Pay*Sv Eletrica e - Parcela 1/3,"553,55"
      
      date_str = row["date"]
      title = row["title"]&.strip
      amount_str = row["amount"]

      begin
        due_date = Date.parse(date_str)
        # Limpa R$, espaços e converte formato brasileiro
        amount = amount_str.to_s.gsub(/[^\d\,\.-]/, "").gsub(".", "").gsub(",", ".").to_d

        installment = nil
        total_installments = nil

        # Verifica se possui parcela no título
        if title.match(/- Parcela (\d+)\/(\d+)/)
          installment = $1.to_i
          total_installments = $2.to_i
          title = title.gsub(/- Parcela \d+\/\d+/, "").strip
        end

        # Busca ou cria a categoria
        category = @user.categories.find_by(name: "Cartão de Crédito")
        if category.nil?
          Rails.logger.info "🏷️ [NubankCreditCard] Criando categoria: 'Cartão de Crédito'"
          category = @user.categories.create!(name: "Cartão de Crédito")
        end

        fingerprint = generate_fingerprint({
          date: date_str,
          title: row["title"],
          amount: amount_str,
          card_id: @wallet.id
        })

        {
          title: title.truncate(100),
          category: category,
          amount: amount.abs,
          transaction_type: amount >= 0 ? :expense : :income, # No Nubank fatura, despesas são positivas e pagamentos negativos
          status: :pending,
          due_date: due_date,
          payment_date: nil,
          installment: installment,
          total_installments: total_installments,
          fingerprint: fingerprint
        }
      rescue Date::Error, ArgumentError => e
        nil
      end
    end
  end
end
