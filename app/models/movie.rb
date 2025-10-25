class Movie < ApplicationRecord
  belongs_to :user
  has_many :comments, dependent: :destroy

  # ORDENAÇÃO OBRIGATÓRIA: mais novo para o mais antigo
  default_scope { order(release_year: :desc) } 

  # Validações básicas (ajuste conforme necessário)
  validates :title, presence: true
  validates :release_year, presence: true, numericality: { only_integer: true, greater_than: 1888 }
end