require "csv"
require "digest"

module TransactionImporters
  class Base
    def initialize(wallet, file_path)
      @wallet = wallet
      @file_path = file_path
      @user = wallet.user
    end

    def import
      transactions_created = 0
      
      content = File.read(@file_path, encoding: 'bom|utf-8')
      
      # Tenta converter caso ainda não seja UTF-8 válido
      unless content.valid_encoding?
        content = content.encode("UTF-8", "iso-8859-1", invalid: :replace, undef: :replace, replace: "")
      end

      # Inter e outras exportações do Windows costumam vir com \r\n
      content = content.gsub("\r\n", "\n")

      CSV.parse(content, **csv_options) do |row|
        next if skip_row?(row)
        
        transaction_data = parse_row(row)
        next unless transaction_data
        
        transaction = @user.transactions.find_or_initialize_by(
          wallet_id: @wallet.is_a?(Wallet) ? @wallet.id : nil,
          credit_card_id: @wallet.is_a?(CreditCard) ? @wallet.id : nil,
          fingerprint: transaction_data[:fingerprint]
        )

        if transaction.new_record?
          transaction.assign_attributes(transaction_data.except(:fingerprint))
          transaction.save!
          transactions_created += 1
        end
      end
      
      transactions_created
    end

    protected

    def csv_options
      { headers: true, col_sep: ",", encoding: "utf-8" }
    end

    def skip_row?(row)
      false
    end

    def parse_row(row)
      raise NotImplementedError
    end

    def generate_fingerprint(data)
      Digest::SHA256.hexdigest(data.values.join("|"))
    end
  end
end
