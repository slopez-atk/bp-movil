class DesempenioSocialController < ApplicationController
  before_action :authenticate_user!

  def index

  end


  def balance_social

  end

  def set_layout
    return "desempenio_social"
    super
  end
end