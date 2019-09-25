class Api::V1::PublicationsController < Api::V1::BaseController
  before_action :set_publication, only: [ :show ]

  def index
    @publications = policy_scope(Publication)
  end

  def show
  end

  private

  def set_publication
    @publication = Publication.find(params[:id])
    authorize @publication  # For Pundit
  end
end
