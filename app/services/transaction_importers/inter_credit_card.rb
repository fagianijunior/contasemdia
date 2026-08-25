module TransactionImporters
  class InterCreditCard < Base
    protected

    def csv_options
      { headers: true, col_sep: ",", quote_char: '"' }
    end

    def skip_row?(row)
      row["Data"].blank? || row["Lançamento"] == "PAGAMENTO ON LINE" || row["Lançamento"] == "PAGAMENTO DE FATURA"
    end

    def parse_row(row)
      # Formato: "Data","Lançamento","Categoria","Tipo","Valor"
      # Ex: "23/08/2026","IOF INTERNACIONAL","OUTROS","Compra à vista","R$ 0,14"
      
      date_str = row["Data"]
      description = row["Lançamento"]&.strip
      category = row["Categoria"]&.strip
      amount_str = row["Valor"]

      begin
        due_date = Date.parse(date_str)
        # Limpa R$, espaços e converte formato brasileiro
        amount = amount_str.to_s.gsub(/[^\d\,\.-]/, "").gsub(".", "").gsub(",", ".").to_d
        
        fingerprint = generate_fingerprint({
          date: date_str,
          description: description,
          amount: amount_str,
          card_id: @wallet.id # @wallet aqui na verdade é @credit_card passado no construtor
        })

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
        nil
      end
    end
  end
end
