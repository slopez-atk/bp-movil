class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :set_layout

  protected
  def set_layout
    return "creditos_judiciales" unless action_name == "dashboard" or action_name == "home"
    "application"
  end
end
