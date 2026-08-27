class Category < ApplicationRecord
  belongs_to :user, optional: true
  has_many :transactions, dependent: :restrict_with_error

  # Definição do Enum para os tipos de categoria
  enum :category_type, %i[expense income]

  validates :name, presence: true
  validates :category_type, presence: true

  # Scopes para buscar categorias do sistema ou do usuário logado
  scope :system_default, -> { where(user_id: nil) }
  scope :for_user, ->(user) { where(user_id: [nil, user.id]) }
end
