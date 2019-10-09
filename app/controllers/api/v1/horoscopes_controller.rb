class Api::V1::HoroscopesController < Api::V1::BaseController
  before_action :set_horoscope, only: [ :show ]

  def show
  end

  def index
    paginate json: policy_scope(Horoscope).by_date, per_page: 25

    # @horoscopes = policy_scope(Horoscope)
  end

  private

  def set_horoscope
    @horoscope = Horoscope.find(params[:id])
    authorize @horoscope # For Pundit
  end
end
