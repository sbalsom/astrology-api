class ApplicationController < ActionController::Base
  include Rails::Pagination
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :expire_hsts

  private
  def expire_hsts
    response.headers["Strict-Transport-Security"] = 'max-age=0'
  end

end
