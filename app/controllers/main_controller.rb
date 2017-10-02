class MainController < ApplicationController
  before_action :authenticate_user!, except: [:home]
  before_action :authenticate_jcreditos, only: [:new_trial, :stage]

  # Pantalla de inicio cuando el usuario no esta autenticado
  def home
  end

  # Controlador de la pantalla principal de todo el sistema
  # donde se listan las herramientas
  def dashboard

  end

  # Controlador de la pantalla principal del modulo de creditos
  def home_creditos
    if current_user.permissions == 5 or current_user.permissions == 4
      @conBienes = Good.activados.ultimos.includes(:good_stage, :good_activity)
      @sinBienes =  WithoutGood.activados.ultimos.includes(:withoutgood_stage, :without_good_activity)
      @insolvencias = Insolvency.activados.ultimos.includes(:insolvency_stage, :insolvency_activity)
    else
      @fechas = HistoryCredit.obtener_fechas_guardadas
    end
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
    # productivos = Oracledb.getCreditosProductivos.to_a
    # microcreditos = Oracledb.getCreditosMicrocreditos.to_a
    # consumos = Oracledb.getCreditosConsumo.to_a

    # @trials = inmobiliarios + productivos + microcreditos + consumos
    @trials = Good.filtrar_creditos(inmobiliarios)
  end

  # Controlador de las busquedas de los juicios por id de credito, socio y cedula
  def search
    if params[:search].present?
      @conBienes = Good.search(params[:search])
      @sinBienes =  WithoutGood.search(params[:search])
      @insolvencias = Insolvency.search(params[:search])
    else
      @conBienes = Good.all.includes(:lawyer, :good_stage, :good_activity)
      @sinBienes = WithoutGood.all.includes(:lawyer, :withoutgood_stage, :without_good_activity)
      @insolvencias = Insolvency.all.includes(:lawyer, :insolvency_stage, :insolvency_activity)
    end


  end

  def evaluacion_resultados
    @cantidades_semafotos = {verdes: 0, rojos: 0, amarillos: 0 }
    @verdes = Array.new
    @amarillos = Array.new
    @rojos = Array.new
    # Consulto todos los juicios excepto los reestructurados y en funcion al semaforo
    # aumento su respeectiva variable para poder graficarlos al ultimo
    Good.activados.each do |trial|
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

    Insolvency.activados.each do | trial|
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

    WithoutGood.activados.each do | trial|
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

  # Metodo accedido por Post para cambiar el estado de un credito
  # segun los parametros que se le envie
  def change_state
    tipo_juicio = params[:tipo_juicio]
    case tipo_juicio
      when "bienes"
        @trial = Good.find(params[:id])
      when "sinbienes"
        @trial = WithoutGood.find(params[:id])
      when "envio_insolvencia"
        @trial = WithoutGood.find(params[:id])
        trial_json = @trial.as_json.to_h
        trial_json.except!("id", "withoutgood_stage_id", "without_good_activity_id", "fcalificacion_juicio","juicio_id","fentrega_juicios","created_at")
        @insolvencia = Insolvency.new(trial_json)
        @insolvencia.credit_id = "I-" + @insolvencia.credit_id
        @insolvencia.estado = "Insolvencia"
        @insolvencia.insolvency_stage = InsolvencyStage.first
        @insolvencia.insolvency_activity = InsolvencyStage.first.insolvency_activities.first
        respond_to do |format|
          if @insolvencia.save
            @trial.update(estado: 'Terminado')
            format.html{ redirect_to @insolvencia, notice: 'Se envió el juicio a insolvencia!'}

          else
            format.html{ redirect_to creditos_root_path, notice: 'Algo salió mal! Intentalo de nuevo'}
          end

        end
        return
      when 'insolvencia'
        @trial = Insolvency.find(params[:id])
    end

    respond_to do |format|
      if @trial.update(estado: params[:state])
        format.html{ redirect_to @trial, notice: 'Se actualizó el estado del crédito'}
      else
        format.html{ redirect_to @trial, notice: 'Algo salió mal! Intentalo de nuevo'}
      end
    end

  end

  def reingresos
    tipo_juicio = params[:tipo_juicio]
    case tipo_juicio
      when "bienes"
        @trial = Good.find(params[:id])
      when "sinbienes"
        @trial = WithoutGood.find(params[:id])
      when "insolvencia"
        @trial = Insolvency.find(params[:id])
    end
    @juicio_reingresado = @trial.dup

    if @juicio_reingresado.credit_id[0] != 'R' and @juicio_reingresado.credit_id[0] != 'I'
      @juicio_reingresado.credit_id = "R-"+@trial.credit_id.to_s
    elsif @juicio_reingresado.credit_id[0] == 'I'
      @juicio_reingresado.credit_id[0] = "R"
    end


    @juicio_reingresado.estado = "Reingreso"
    respond_to do |format|
      if @juicio_reingresado.save
        @trial.update(estado: "Abandono")
        format.html{ redirect_to @juicio_reingresado, notice: 'Se reingresó exitosamente el crédito'}
      else
        format.html{ redirect_to @juicio_reingresado, notice: 'Algo salió mal! Intentalo de nuevo'}
      end
    end
  end

  def listado_juicios
    case params[:estado]
      when "Terminado"
        @conBienes = Good.terminados.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.terminados.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.terminados.includes(:lawyer, :insolvency_stage, :insolvency_activity)
      when "Cancelado"
        @conBienes = Good.cancelados.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.cancelados.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.cancelados.includes(:lawyer, :insolvency_stage, :insolvency_activity)
      when "Insolvencia"
        @conBienes = Good.insolvencias.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.insolvencias.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.insolvencias.includes(:lawyer, :insolvency_stage, :insolvency_activity)
      when "Abandono"
        @conBienes = Good.abandonados.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.abandonados.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.abandonados.includes(:lawyer, :insolvency_stage, :insolvency_activity)
      when "Reestructurado"
        @conBienes = Good.reestructurados.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.reestructurados.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.reestructurados.includes(:lawyer, :insolvency_stage, :insolvency_activity)
      when "Reingreso"
        @conBienes = Good.reingresos.includes(:lawyer, :good_stage, :good_activity)
        @sinBienes = WithoutGood.reingresos.includes(:lawyer, :withoutgood_stage, :without_good_activity)
        @insolvencias = Insolvency.reingresos.includes(:lawyer, :insolvency_stage, :insolvency_activity)
    end
  end

  def set_layout
    return "creditos_judiciales" if action_name == "home_creditos" or action_name == "new_trial" or action_name == "evaluacion_resultados" or action_name == "search"or action_name == "listado_juicios"
    return "creditos_judiciales" if action_name == "stage"
    super
  end
end
