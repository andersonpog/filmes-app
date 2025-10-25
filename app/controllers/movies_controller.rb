class MoviesController < ApplicationController
  # Ações públicas (sem login): listagem e detalhes
  before_action :authenticate_user!, except: [:index, :show] 

  before_action :set_movie, only: %i[ show edit update destroy ]
  # Restringe EDIT, UPDATE e DESTROY apenas para o criador do filme
  before_action :authorize_movie_owner, only: %i[ edit update destroy ] 

  # Área Pública: Listagem e Paginação
  def index
    # Paginação: 6 filmes por página, ordenado pelo default_scope (mais novo)
    @pagy, @movies = pagy(Movie.all, items: 6) 
  end

  # Área Pública: Detalhes do Filme
  def show
    # Comentários exibidos do mais recente para o mais antigo.
    @comments = @movie.comments.order(created_at: :desc)
    @comment = @movie.comments.build # Para o formulário de novo comentário
  end

  # Área Autenticada: Novo Filme
  def new
    @movie = current_user.movies.build
  end

  # Área Autenticada: Criação de Filme
  def create
    # Associa automaticamente o filme ao usuário logado
    @movie = current_user.movies.new(movie_params) 

    if @movie.save
      redirect_to @movie, notice: "Filme cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # Área Autenticada: Edição de Filme
  def edit
  end

  def update
    if @movie.update(movie_params)
      redirect_to @movie, notice: "Filme atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # Área Autenticada: Exclusão de Filme
  def destroy
    @movie.destroy!
    redirect_to movies_url, notice: "Filme apagado com sucesso."
  end

  private
    def set_movie
      @movie = Movie.find(params[:id])
    end

    def authorize_movie_owner
      unless @movie.user == current_user
        redirect_to movies_url, alert: "Você só pode editar ou apagar filmes criados por você."
      end
    end

    def movie_params
      params.require(:movie).permit(:title, :synopsis, :release_year, :duration, :director)
    end
end