Rails.application.routes.draw do
  # resources :movies
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html


  get "up" => "rails/health#show", as: :rails_health_check


  # Defines the root path route ("/")
  # root "movies#index"
  # Rotas de Autenticação (Login, Cadastro, etc.)
  # devise_for :users

  # Rotas de Filmes (CRUD)
  resources :movies do
    # Rotas aninhadas para Comentários (apenas criar e apagar)
    resources :comments, only: [:create, :destroy] 
  end

  # Área pública: listagem de todos os filmes (página inicial)
  root "movies#index"
end
