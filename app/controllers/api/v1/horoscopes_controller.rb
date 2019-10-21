class Api::V1::HoroscopesController < Api::V1::BaseController
  before_action :set_horoscope, only: [ :show ]

  def show
  end

  def index
    if params
      paginate json: policy_scope(Horoscope.filter(params)).by_date, per_page: 25
    else
      paginate json: policy_scope(Horoscope).by_date, per_page: 25
    end
  end

  private

  def set_horoscope
    @horoscope = Horoscope.find(params[:id])
    authorize @horoscope # For Pundit
  end
end
