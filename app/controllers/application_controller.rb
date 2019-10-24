class ApplicationController < ActionController::Base
  include Rails::Pagination
  include Pundit
  protect_from_forgery with: :exception
  before_action :authenticate_user!
end
