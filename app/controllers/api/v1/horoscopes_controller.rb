class Api::V1::HoroscopesController < Api::V1::BaseController
  before_action :set_horoscope, only: [ :show ]

  def show
  end

  def index
    if params[:range_in_days]
      paginate json: policy_scope(Horoscope)
      .where(range_in_days: params[:range_in_days])
      .by_date, per_page: 25
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

    # t.bigint "publication_id"
    # t.bigint "author_id"
    # t.text "content"
    # t.date "start_date"
    # t.bigint "zodiac_sign_id"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.integer "range_in_days"
    # t.string "keywords", default: [], array: true
    # t.string "original_link"
    # t.integer "word_count"
    # t.string "mood"
    # t.index ["author_id"], name: "index_horoscopes_on_author_id"
    # t.index ["publication_id"], name: "index_horoscopes_on_publication_id"
    # t.index ["zodiac_sign_id"], name: "index_horoscopes_on_zodiac_sign_id"
