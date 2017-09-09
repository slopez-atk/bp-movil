class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :set_layout

  protected
  def set_layout
    "application"
  end
end
