# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.find_or_create_by!(email_address: "fagianijunior@gmail.com") do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
end

Bank.find_or_create_by!(name: "Inter&Co") do |bank|
  bank.code = "077"
  bank.color = "#FF6500"
  bank.logo_url = "banks/inter_logo.png"
end

Bank.find_or_create_by!(name: "NuBank") do |bank|
  bank.code = "260"
  bank.color = "#820AD1"
  bank.logo_url = "banks/nubank_logo.svg"
end

# db/seeds.rb

puts "🌱 Semeando categorias padrão do sistema..."

# Array de Categorias de Despesas
EXPENSE_CATEGORIES = [
  { name: "Alimentação",       icon: "utensils",       category_type: :expense },
  { name: "Supermercado",      icon: "shopping-cart",   category_type: :expense },
  { name: "Moradia",           icon: "home",            category_type: :expense },
  { name: "Transporte",        icon: "car",             category_type: :expense },
  { name: "Saúde",             icon: "heart-pulse",     category_type: :expense },
  { name: "Lazer e Lazer",     icon: "film",            category_type: :expense },
  { name: "Educação",          icon: "graduation-cap",  category_type: :expense },
  { name: "Assinaturas e TV",  icon: "tv",              category_type: :expense },
  { name: "Compras Pessoais",  icon: "bag-shopping",    category_type: :expense },
  { name: "Impostos e Taxas",  icon: "receipt",         category_type: :expense },
  { name: "Viagens",           icon: "plane",           category_type: :expense },
  { name: "Outras Despesas",   icon: "ellipsis",        category_type: :expense }
].freeze

# Array de Categorias de Receitas
INCOME_CATEGORIES = [
  { name: "Salário",           icon: "briefcase",       category_type: :income },
  { name: "Rendimentos",       icon: "chart-line",      category_type: :income },
  { name: "Investimentos",     icon: "piggy-bank",      category_type: :income },
  { name: "Freelance",         icon: "laptop-code",     category_type: :income },
  { name: "Vendas",            icon: "store",           category_type: :income },
  { name: "Presentes",         icon: "gift",            category_type: :income },
  { name: "Reembolso",         icon: "rotate-left",     category_type: :income },
  { name: "Outras Receitas",   icon: "coins",           category_type: :income }
].freeze

# Popula Despesas Globais
EXPENSE_CATEGORIES.each do |cat|
  Category.find_or_create_by!(name: cat[:name], user_id: nil) do |c|
    c.icon = cat[:icon]
    c.category_type = cat[:category_type]
  end
end

# Popula Receitas Globais
INCOME_CATEGORIES.each do |cat|
  Category.find_or_create_by!(name: cat[:name], user_id: nil) do |c|
    c.icon = cat[:icon]
    c.category_type = cat[:category_type]
  end
end

puts "✅ #{Category.where(user_id: nil).count} categorias padrão do sistema criadas com sucesso!"