class Api::V1::AuthorsController < Api::V1::BaseController
  before_action :set_author, only: [:show]

  def show
  end

  def index
    if params
      paginate json: policy_scope(Author.filter(params)).by_date, per_page: 25
    else
      paginate json: policy_scope(Author).by_date, per_page: 25
    end
  end

  private

  def set_author
    @author = Author.find(params[:id])
    authorize @author # For Pundit
  end
end
