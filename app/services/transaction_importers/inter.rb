module TransactionImporters
  class Inter < Base
    protected

    def csv_options
      { 
        headers: false, 
        col_sep: ";",
        liberal_parsing: true,
        quote_char: '"',
        skip_blanks: false
      }
    end

    def skip_row?(row)
      # Pula cabeçalhos e linhas de saldo
      return true if row[0].nil?
      return true unless row[0].match?(/\d{2}\/\d{2}\/\d{4}/)
      false
    end

    def parse_row(row)
      # Formato: Data Lançamento;Histórico;Descrição;Valor;Saldo
      # Ex: 20/08/2026;Pix enviado ;Francisco Sergio Tabosa Maciel;-45,00;109,02
      
      date_str = row[0]
      history = row[1]&.strip
      description = row[2]&.strip
      amount_str = row[3]

      begin
        due_date = Date.parse(date_str)
        amount = amount_str.gsub(".", "").gsub(",", ".").to_d
        
        # O Inter não fornece ID único por transação no CSV, então usamos fingerprint
        fingerprint = generate_fingerprint({
          date: date_str,
          history: history,
          description: description,
          amount: amount_str,
          wallet_id: @wallet.id
        })

        {
          title: "#{history} - #{description}".truncate(100),
          amount: amount.abs,
          transaction_type: amount >= 0 ? :income : :expense,
          status: :paid,
          due_date: due_date,
          payment_date: due_date,
          fingerprint: fingerprint
        }
      rescue Date::Error, ArgumentError
        nil
      end
    end
  end
end
