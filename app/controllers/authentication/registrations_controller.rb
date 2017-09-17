class Authentication::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  protected
  def set_layout
    return "creditos_judiciales" if action_name == "edit"
  end
end