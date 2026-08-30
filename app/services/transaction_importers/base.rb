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
      Rails.logger.info "📥 [CSV Import] Arquivo lido: #{@file_path}"
      Rails.logger.info "📥 [CSV Import] Tamanho original: #{content.bytesize} bytes"
      
      # Tenta converter caso ainda não seja UTF-8 válido
      unless content.valid_encoding?
        Rails.logger.warn "⚠️ [CSV Import] Encoding inválido detectado, convertendo ISO-8859-1 → UTF-8"
        content = content.encode("UTF-8", "iso-8859-1", invalid: :replace, undef: :replace, replace: "")
      end

      # Remove qualquer BOM residual que possa estar presente
      if content.start_with?("\xEF\xBB\xBF")
        Rails.logger.info "🧹 [CSV Import] BOM removido"
        content = content.sub(/^\xEF\xBB\xBF/, '')
      end

      # Remove line ending variations (Windows vs Unix)
      # Inter e outras exportações do Windows costumam vir com \r\n
      content = content.gsub("\r\n", "\n")

      # Log da primeira linha para debug
      first_line = content.lines.first
      Rails.logger.info "📋 [CSV Import] Primeira linha (#{first_line.bytesize} bytes): #{first_line.inspect}"

      # Normaliza espaços especiais que podem aparecer em valores, mas preserva estrutura CSV
      # Non-breaking space (U+00A0) - normalmente aparece em valores monetários
      nbsp_count = content.count("\xC2\xA0")
      content = content.gsub("\xC2\xA0", " ")
      Rails.logger.info "🧹 [CSV Import] #{nbsp_count} non-breaking spaces normalizados" if nbsp_count > 0

      # Ideographic space (U+3000)
      idsp_count = content.count("\xE3\x80\x80")
      content = content.gsub("\xE3\x80\x80", " ")
      Rails.logger.info "🧹 [CSV Import] #{idsp_count} ideographic spaces normalizados" if idsp_count > 0

      # Narrow non-breaking space (U+202F)
      nnbsp_count = content.count("\xE2\x80\xAF")
      content = content.gsub("\xE2\x80\xAF", " ")
      Rails.logger.info "🧹 [CSV Import] #{nnbsp_count} narrow non-breaking spaces normalizados" if nnbsp_count > 0

      # Log da primeira linha após normalização
      first_line_cleaned = content.lines.first
      Rails.logger.info "📋 [CSV Import] Primeira linha após normalização: #{first_line_cleaned.inspect}"

      begin
        CSV.parse(content, **csv_options) do |row|
          Rails.logger.debug "🔍 [CSV Import] Linha parseada: #{row.inspect}"
          
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
            Rails.logger.info "✅ [CSV Import] Transação criada: #{transaction_data[:title]} (#{transaction_data[:amount]})"
          else
            Rails.logger.debug "⏭️ [CSV Import] Transação duplicada, pulando: #{transaction_data[:fingerprint]}"
          end
        end
        Rails.logger.info "✨ [CSV Import] Importação concluída! #{transactions_created} transações criadas"
      rescue CSV::MalformedCSVError => e
        Rails.logger.error "❌ [CSV Import] Erro de formatação CSV: #{e.class} - #{e.message}"
        Rails.logger.error "❌ [CSV Import] Tentando estratégia alternativa com strict_parsing desabilitado..."
        
        # Tenta novamente com opções mais permissivas
        begin
          alternative_options = csv_options.merge(
            liberal_parsing: true,
            skip_blanks: true
          )
          
          CSV.parse(content, **alternative_options) do |row|
            Rails.logger.debug "🔍 [CSV Import] Linha parseada (alternativa): #{row.inspect}"
            
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
              Rails.logger.info "✅ [CSV Import] Transação criada (estratégia alternativa): #{transaction_data[:title]} (#{transaction_data[:amount]})"
            end
          end
          Rails.logger.info "✨ [CSV Import] Importação concluída (estratégia alternativa)! #{transactions_created} transações criadas"
        rescue => alternative_error
          Rails.logger.error "❌ [CSV Import] Estratégia alternativa também falhou: #{alternative_error.class} - #{alternative_error.message}"
          raise e  # Re-raise the original error
        end
      rescue StandardError => e
        Rails.logger.error "❌ [CSV Import] Erro ao processar CSV: #{e.class} - #{e.message}"
        Rails.logger.error "❌ [CSV Import] Backtrace: #{e.backtrace.first(5).join("\n")}"
        raise
      end
      
      transactions_created
    end

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
