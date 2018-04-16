class ApplicationController < ActionController::Base
  # protect_from_forgery with: :exception
  layout :set_layout

  protected
  def set_layout
    "application"
  end

  def authenticate_admin
    if current_user.admin != true
      redirect_to root_path, notice: "No estas autorizado!"
    end
  end

  def authenticate_jcreditos
    if !current_user.admin
      if current_user.permissions != 5
        redirect_to root_path, notice: "No estas autorizado!"
      end
    end
  end
end
