class CommentsController < ApplicationController
  # Requer que o usuário esteja logado apenas para a ação de apagar
  before_action :authenticate_user!, only: [:destroy]
  before_action :set_movie

  # ----------------------------------------------------
  # Ação: CREATE (Permite Anônimo ou Autenticado)
  # ----------------------------------------------------
  def create
    @comment = @movie.comments.new(comment_params)

    # Se o usuário estiver logado, vincula o comentário a ele
    if user_signed_in?
      @comment.user = current_user
      # O nome do usuário autenticado será derivado do User (ex: email),
      # então o 'commenter_name' do formulário é ignorado neste caso.
    end

    if @comment.save
      redirect_to @movie, notice: "Comentário postado com sucesso."
    else
      # Se a validação falhar (ex: comentário vazio ou anônimo sem nome),
      # recarrega a página de detalhes do filme com a lista de erros.
      # Nota: Para lidar com isso de forma correta, precisaríamos re-renderizar
      # a view 'movies/show', mas o redirect é mais simples por enquanto.
      redirect_to @movie, alert: "Erro ao postar comentário: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  # ----------------------------------------------------
  # Ação: DESTROY (Apenas para Usuários Autenticados)
  # ----------------------------------------------------
  def destroy
    @comment = @movie.comments.find(params[:id])

    # Autorização: Apenas o criador (autenticado) pode apagar.
    # Usuários anônimos não possuem permissão para apagar comentários.
    if @comment.user == current_user 
      @comment.destroy
      notice_message = "Comentário apagado com sucesso."
    else
      notice_message = "Você não tem permissão para apagar este comentário."
    end

    redirect_to @movie, notice: notice_message
  end

  private

  def set_movie
    @movie = Movie.find(params[:movie_id])
  end

  def comment_params
    # Permite 'content' e 'commenter_name'. O 'user_id' é preenchido manualmente
    # pelo controller se o usuário estiver logado.
    params.require(:comment).permit(:content, :commenter_name) 
  end
end