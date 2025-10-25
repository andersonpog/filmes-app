class Comment < ApplicationRecord
  belongs_to :movie
  # user_id pode ser nulo para comentários anônimos
  belongs_to :user, optional: true 

  # Regra de Validação OBRIGATÓRIA: Deve ter conteúdo
  validates :content, presence: true

  # Regra OBRIGATÓRIA: Se não estiver autenticado (user_id é nil), o nome deve ser fornecido.
  validates :commenter_name, presence: true, unless: :user_id? 

  # Regra: Se estiver autenticado, não precisa de nome (o nome será o email/nome do usuário)
  validates :user_id, presence: true, if: -> { commenter_name.blank? }
end