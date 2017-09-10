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

  def stage
    @conBienes = GoodStage.all
    @sinBienes = WithoutgoodStage.all
    @insolvencias = InsolvencyStage.all
  end

  def new_trial
    inmobiliarios = Oracledb.getCreditosInmobiliarios.to_a
    productivos = Oracledb.getCreditosProductivos.to_a
    microcreditos = Oracledb.getCreditosMicrocreditos.to_a
    consumos = Oracledb.getCreditosConsumo.to_a

    @trials = inmobiliarios + productivos + microcreditos + consumos
    @trials = Good.filtrar_creditos(@trials)
  end

  def set_layout
    return "creditos_judiciales" if action_name == "home_creditos" or action_name == "new_trial"
    return "creditos_judiciales" if action_name == "stage"
    super
  end
end
