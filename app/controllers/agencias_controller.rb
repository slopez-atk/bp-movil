class AgenciasController < ApplicationController
  before_action :authenticate_user!
  def index

  end

  def indicadores_financieros

  end

  def set_layout
    return "agencias"
    super
  end

end