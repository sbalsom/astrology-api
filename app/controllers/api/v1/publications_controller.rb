class Api::V1::PublicationsController < Api::V1::BaseController
  before_action :set_publication, only: [:show]

  def index
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
