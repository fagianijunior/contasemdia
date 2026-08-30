module TransactionImporters
  class Nubank < Base
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

    def parse_row(row)
      # Formato: Data,Valor,Identificador,Descrição
      # Ex: 05/09/2024,4093.65,66d9e643-e6b6-4cfa-a0ec-d91ce3b83bc5,Transferência recebida pelo Pix...
      
      date_str = row["Data"]
      amount_str = row["Valor"]
      external_id = row["Identificador"]
      description = row["Descrição"]

      begin
        due_date = Date.parse(date_str)
        amount = amount_str.to_d

        # Nubank fornece um identificador (UUID)
        {
          title: description.truncate(100),
          amount: amount.abs,
          transaction_type: amount >= 0 ? :income : :expense,
          status: :paid,
          due_date: due_date,
          payment_date: due_date,
          external_id: external_id,
          fingerprint: external_id # Usamos o ID como fingerprint também para consistência
        }
      rescue Date::Error, ArgumentError
        nil
      end
    end
  end
end
