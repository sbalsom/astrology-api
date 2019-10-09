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
    if params[:name]
      paginate json: policy_scope(Publication)
        .where(name: params[:name])
        .by_date, per_page: 25
    else
      paginate json: policy_scope(Publication).by_date, per_page: 25
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
