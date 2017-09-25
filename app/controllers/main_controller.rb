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
    @conBienes = Good.activos.ultimos.includes(:good_stage, :good_activity)
    @sinBienes =  WithoutGood.activos.ultimos.includes(:withoutgood_stage, :without_good_activity)
    @insolvencias = Insolvency.activos.ultimos.includes(:insolvency_stage, :insolvency_activity)
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

  # Controlador de las busquedas de los juicios por id de credito, socio y cedula
  def search
    if params[:search].present?
      @conBienes = Good.search(params[:search])
      @sinBienes =  WithoutGood.search(params[:search])
      @insolvencias = Insolvency.search(params[:search])
    else
      @conBienes
      @sinBienes
      @insolvencias
    end


  end

  def evaluacion_resultados
    @cantidades_semafotos = {verdes: 0, rojos: 0, amarillos: 0 }
    @verdes = Array.new
    @amarillos = Array.new
    @rojos = Array.new
    # Consulto todos los juicios excepto los reestructurados y en funcion al semaforo
    # aumento su respeectiva variable para poder graficarlos al ultimo
    Good.sin_reestructurados.each do |trial|
      if trial.semaforo[0] == 'rojo'
        @cantidades_semafotos[:rojos] = @cantidades_semafotos[:rojos] + 1
        @rojos.push(trial)
      elsif trial.semaforo[0] == 'amarillo'
        @cantidades_semafotos[:amarillos] = @cantidades_semafotos[:amarillos] + 1
        @amarillos.push(trial)
      else
        @cantidades_semafotos[:verdes] = @cantidades_semafotos[:verdes] + 1
        @verdes.push(trial)
      end
    end

    Insolvency.sin_reestructurados.each do | trial|
      if trial.semaforo[0] == 'rojo'
        @cantidades_semafotos[:rojos] = @cantidades_semafotos[:rojos] + 1
        @rojos.push(trial)
      elsif trial.semaforo[0] == 'amarillo'
        @cantidades_semafotos[:amarillos] = @cantidades_semafotos[:amarillos] + 1
        @amarillos.push(trial)
      else
        @cantidades_semafotos[:verdes] = @cantidades_semafotos[:verdes] + 1
        @verdes.push(trial)
      end
    end

    WithoutGood.sin_reestructurados.each do | trial|
      if trial.semaforo[0] == 'rojo'
        @cantidades_semafotos[:rojos] = @cantidades_semafotos[:rojos] + 1
        @rojos.push(trial)
      elsif trial.semaforo[0] == 'amarillo'
        @cantidades_semafotos[:amarillos] = @cantidades_semafotos[:amarillos] + 1
        @amarillos.push(trial)
      else
        @cantidades_semafotos[:verdes] = @cantidades_semafotos[:verdes] + 1
        @verdes.push(trial)
      end
    end

    @total_semaforos = @cantidades_semafotos[:amarillos] + @cantidades_semafotos[:verdes] + @cantidades_semafotos[:rojos]

    # Para obtener los valores de los juicios segun su estado
    @estado_juicios = {Activos: Good.activos.count + Insolvency.activos.count + WithoutGood.activos.count,
                       Terminados: Good.terminados.count + Insolvency.terminados.count + WithoutGood.terminados.count,
                       Reingresos: Good.reingresos.count + Insolvency.reingresos.count + WithoutGood.reingresos.count,
                       Insolvencia: Good.insolvencias.count + Insolvency.insolvencias.count + WithoutGood.insolvencias.count,
                       Abandono: Good.abandonados.count + Insolvency.abandonados.count + WithoutGood.abandonados.count
    }


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
    return "creditos_judiciales" if action_name == "home_creditos" or action_name == "new_trial" or action_name == "evaluacion_resultados" or action_name == "search"
    return "creditos_judiciales" if action_name == "stage"
    super
  end
end
