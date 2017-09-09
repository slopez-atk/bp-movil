class MainController < ApplicationController
  before_action :authenticate_user!, except: [:home]

  def home
  end

  def dashboard

  end

  def home_creditos
    @conBienes = Good.all
    @sinBienes =  WithoutGood.all
    @insolvencias = Insolvency.all
  end

  def set_layout
    return "creditos_judiciales" if action_name == "home_creditos"
    super
  end
end
