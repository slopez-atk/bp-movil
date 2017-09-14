class MainController < ApplicationController
  before_action :authenticate_user!, except: [:home]

  # Pantalla de inicio cuando el usuario no esta autenticado
  def home
  end

  # Controlador de la pantalla principal de todo el sistema
  # donde se listan las herramientas
  def dashboard

  end

  # Controlador de la pantalla principal del modulo de creditos
  def home_creditos
    @conBienes = Good.includes(:good_stage, :good_activity)
    @sinBienes =  WithoutGood.includes(:withoutgood_stage, :without_good_activity)
    @insolvencias = Insolvency.includes(:insolvency_stage, :insolvency_activity)
  end

  # Controlador de la pantalla de las etapas y procesos
  def stage
    @conBienes = GoodStage.all
    @sinBienes = WithoutgoodStage.all
    @insolvencias = InsolvencyStage.all
  end

  # Controlador de la pantalla de la Jefatura de Credito en donde
  # se listan los creditos filtrados desde la bdd Oracle
  def new_trial
    inmobiliarios = Oracledb.getCreditosInmobiliarios.to_a
    productivos = Oracledb.getCreditosProductivos.to_a
    microcreditos = Oracledb.getCreditosMicrocreditos.to_a
    consumos = Oracledb.getCreditosConsumo.to_a

    @trials = inmobiliarios + productivos + microcreditos + consumos
    @trials = Good.filtrar_creditos(@trials)
  end

  # Controlador para poder crear un pending_trial, estos son los creditos que
  # se autorizan desde la jefatura de credito para que pueda ser enviado
  # a juicio
  def create_trial
    trial = params[:trial]
    pending_trial = PendingTrial.new
    pending_trial.bienes= trial["BIENES"]
    pending_trial.calificacion_propia= trial["CALIFICACION_PROPIA"]
    pending_trial.canton= trial["CANTON"]
    pending_trial.cartera_heredada= trial["CARTERA_HEREDADA"]
    pending_trial.cedula= trial["CEDULA"]
    pending_trial.celular= trial["CELULAR"]
    pending_trial.direccion= trial["DIRECCION"]
    pending_trial.dir_garante= trial["DIRECCION_GARANTE"]
    pending_trial.fecha_concesion= trial["FECHA_CONCESION"]
    pending_trial.fecha_vencimiento= trial["FECHA_VENCIMIENTO"]
    pending_trial.garantia_fiduciaria= trial["GARANTIA_FIDUCIARIA"]
    pending_trial.garantia_real= trial["GARANTIA_REAL"]
    pending_trial.credit_id= trial["ID_CREDITO"]
    pending_trial.socio_id= trial["ID_SOCIO"]
    pending_trial.nombres= trial["NOMBRE"]
    pending_trial.nombre_grupo= trial["NOM_GRUPO"]
    pending_trial.sucursal= trial["OFICINA"]
    pending_trial.oficial_credito= trial["OF_CRED"]
    pending_trial.parroquia= trial["PARROQUIA"]
    pending_trial.sector= trial["SECTOR"]
    pending_trial.telefono= trial["TELEFONO"]
    pending_trial.tel_garante= trial["TELEFONO_GARANTE"]
    pending_trial.tipo_credito= trial["TIPO_CREDITO"]
    pending_trial.tipo_garantia= trial["TIPO_GARANTIA"]
    pending_trial.valor_cartera_castigada= trial["VALOR_CARTERA_CASTIGADA"]

    respond_to do |format|
      if pending_trial.save
        format.html { redirect_to new_trials_root_path, notice: 'Credito autorizado' }
      else
        format.html { redirect_to new_trials_root_path, notice: "Algo salio mal!" }
      end
    end

  end

  def set_layout
    return "creditos_judiciales" if action_name == "home_creditos" or action_name == "new_trial"
    return "creditos_judiciales" if action_name == "stage"
    super
  end
end
