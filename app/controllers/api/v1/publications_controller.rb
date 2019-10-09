class Api::V1::PublicationsController < Api::V1::BaseController
  before_action :set_publication, only: [:show]

  def index
    # paginate policy_scope(Publication), per_page: 15
    # publications = policy_scope(Publication).page(params[:page]).per(15)

    # render json: publications,
    # meta: {
    #   pagination: {
    #     per_page: 15,
    #     total:10,
    #     total_publications: 150
    #   }
    # }

    #     @publications = policy_scope(Publication)
    # paginate @publicatons, per_page: 20
    if params
      logger.debug "The params are #{params}"
      @publications = policy_scope(Publication).where(name: params[:name])
    else
      @publications = policy_scope(Publication).first(5)
      # @publications = policy_scope(Publication)
    end


  end

  def show
  end

  private

  def set_publication
    @publication = Publication.find(params[:id])
    authorize @publication  # For Pundit
  end
end



# TODO : paginate api views
# don't use json builders
# define the params as they are to be called and document
