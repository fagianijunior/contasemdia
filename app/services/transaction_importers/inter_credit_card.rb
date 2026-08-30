module TransactionImporters
  class InterCreditCard < Base
    protected

    def csv_options
      { 
        headers: true, 
        col_sep: ",", 
        liberal_parsing: true,
        quote_char: '"',
        skip_blanks: false
      }
    end

    def skip_row?(row)
      row["Data"].blank? || row["Lançamento"] == "PAGAMENTO ON LINE" || row["Lançamento"] == "PAGAMENTO DE FATURA"
    end

    def parse_row(row)
      # Formato: "Data","Lançamento","Categoria","Tipo","Valor"
      # Ex: "23/08/2026","IOF INTERNACIONAL","OUTROS","Compra à vista","R$ 0,14"
      date_str = row["Data"]
      description = row["Lançamento"]&.strip
      category_name = row["Categoria"]&.strip
      amount_str = row["Valor"]
      
      begin
        Rails.logger.debug "🔧 [InterCreditCard] Parseando: Data=#{date_str.inspect}, Descrição=#{description.inspect}, Categoria=#{category_name.inspect}, Valor=#{amount_str.inspect}"
        
        due_date = Date.parse(date_str)
        Rails.logger.debug "📅 [InterCreditCard] Data parseada: #{due_date.inspect}"
        
        # Limpa R$, espaços e converte formato brasileiro
        amount = amount_str.to_s.gsub(/[^\d\,\.-]/, "").gsub(".", "").gsub(",", ".").to_d
        Rails.logger.debug "💰 [InterCreditCard] Valor parseado: #{amount.inspect}"
        
        # Busca ou cria a categoria pelo nome
        category = nil
        if category_name.present?
          category = @user.categories.find_by(name: category_name)
          if category.nil?
            Rails.logger.info "🏷️ [InterCreditCard] Criando categoria: #{category_name.inspect}"
            category = @user.categories.create!(name: category_name)
          end
        end
        
        fingerprint = generate_fingerprint({
          date: date_str,
          description: description,
          amount: amount_str,
          card_id: @wallet.id # @wallet aqui na verdade é @credit_card passado no construtor
        })
        Rails.logger.debug "🔐 [InterCreditCard] Fingerprint: #{fingerprint.inspect}"

        {
          title: description.truncate(100),
          category: category,
          amount: amount.abs,
          transaction_type: :expense, # Lançamentos no cartão são despesas
          status: :pending, # Depende do fechamento da fatura, mas podemos deixar pending/paid
          due_date: due_date,
          payment_date: nil,
          fingerprint: fingerprint
        }
      rescue Date::Error, ArgumentError => e
        Rails.logger.warn "⚠️ [InterCreditCard] Erro ao parsear linha: #{e.class} - #{e.message}"
        Rails.logger.debug "⚠️ [InterCreditCard] Row: #{row.inspect}"
        nil
      rescue StandardError => e
        Rails.logger.error "❌ [InterCreditCard] Erro inesperado: #{e.class} - #{e.message}"
        Rails.logger.debug "❌ [InterCreditCard] Row: #{row.inspect}"
        raise
      end
    end
  end
end
