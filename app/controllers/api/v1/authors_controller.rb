class Api::V1::AuthorsController < Api::V1::BaseController
  before_action :set_author, only: [ :show ]

  def show
  end

  def index
    # either scrape directly here or call the model which will have a method to populate itself
    @authors = policy_scope(Author)
  end

  private

  def set_author
    @author = Author.find(params[:id])
    authorize @author # For Pundit
  end
end
