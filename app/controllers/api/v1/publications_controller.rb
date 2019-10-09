class Api::V1::PublicationsController < Api::V1::BaseController
  before_action :set_publication, only: [:show]

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end

  def index
    paginate json: policy_scope(Publication).by_date, per_page: 25
  #   publications = Publication.page(params[:page] ? params[:page].to_i : 1)
  # render json: {
  #               pubs: publications,
  #               meta: pagination_meta(publications)
  #             }
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

    # if params[:name]
    #   logger.debug "The params are #{params}"
    #   @publications = policy_scope(Publication).where(name: params[:name])
    # else
    #   logger.debug "I'm in the else!"
    #   @publications = policy_scope(Publication)
    #   # @publications = policy_scope(Publication)
    # end


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
