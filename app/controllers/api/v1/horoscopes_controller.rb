class Api::V1::HoroscopesController < Api::V1::BaseController
  before_action :set_horoscope, only: [ :show ]

  def show
  end

  def index
    # either scrape directly here or call the model which will have a method to populate itself
    @horoscopes = policy_scope(Horoscope)
  end

  private

  def set_horoscope
    @horoscope = Horoscope.find(params[:id])
    authorize @horoscope # For Pundit
  end
end
