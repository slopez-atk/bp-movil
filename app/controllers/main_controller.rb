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
    # inmobiliarios = Oracledb.getCreditosInmobiliarios.to_a
    # productivos = Oracledb.getCreditosProductivos.to_a
    # microcreditos = Oracledb.getCreditosMicrocreditos.to_a
    # consumos = Oracledb.getCreditosConsumo.to_a
    # @trials = inmobiliarios + productivos + microcreditos + consumos

    @trials = Good.filtrar_creditos(Oracledb.obtener_creditos_pendientes)
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
    pending_trial.bienes= trial["bienes"]
    pending_trial.calificacion_propia= trial["calificacion_propia"]
    pending_trial.canton= trial["canton"]
    pending_trial.cartera_heredada= trial["cartera_heredada"]
    pending_trial.cedula= trial["cedula"]
    pending_trial.celular= trial["celular"]
    pending_trial.direccion= trial["direccion"]
    pending_trial.dir_garante= trial["direccion_garante"]
    pending_trial.fecha_concesion= trial["fecha_concesion"]
    pending_trial.fecha_vencimiento= trial["fecha_vencimiento"]
    pending_trial.garantia_fiduciaria= trial["garantia_fiduciaria"]
    pending_trial.garantia_real= trial["garantia_real"]
    pending_trial.credit_id= trial["id_credito"]
    pending_trial.socio_id= trial["id_socio"]
    pending_trial.nombres= trial["nombres"]
    pending_trial.nombre_grupo= trial["nom_grupo"]
    pending_trial.sucursal= trial["oficina"]
    pending_trial.oficial_credito= trial["of_cred"]
    pending_trial.parroquia= trial["parroquia"]
    pending_trial.sector= trial["sector"]
    pending_trial.telefono= trial["telefono"]
    pending_trial.tel_garante= trial["telefono_garante"]
    pending_trial.tipo_credito= trial["tipo_credito"]
    pending_trial.tipo_garantia= trial["tipo_garantia"]
    pending_trial.valor_cartera_castigada= trial["valor_cartera_castigada"]

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

  # Metodo para cambiar de la tabla de bienes a sin bienes y viceversa, un  determinado juicio
  def change_trial_type
    juicio_id = params[:juicio]
    estado_actual = params[:estado_actual]
    if estado_actual == 'bienes'
      juicio = Good.find(juicio_id)
      datos = juicio.as_json.dup.except!("id","good_stage_id", "good_activity_id")
      nuevo_juicio = WithoutGood.new(datos)
      nuevo_juicio.withoutgood_stage_id = 1#WithoutgoodStage.find_by_name(juicio.good_stage.name)
      nuevo_juicio.without_good_activity_id = 1
      nuevo_juicio.callback_skip = true
      puts "\n ===== Datos del juicio ===== \n"
      puts nuevo_juicio
      puts "\n ======= Dato de la etapa ===== \n"
      puts WithoutgoodStage.find_by_name(juicio.good_stage.name)
      respond_to do |format|
        if nuevo_juicio.save
          nuevo_juicio.update(created_at: juicio.created_at, updated_at: juicio.updated_at)
          juicio.destroy
          format.html{ redirect_to nuevo_juicio, notice: 'Se cambio el juicio exitosamente'}
        else
          format.html{ redirect_to root_path, notice: 'Algo salió mal! Intentalo de nuevo'}
        end
      end
    else
      juicio = WithoutGood.find(juicio_id)
      datos = juicio.as_json.dup.except!("id","withoutgood_stage_id", "without_good_activity_id")
      nuevo_juicio = Good.new(datos)
      nuevo_juicio.good_stage_id = 1#GoodStage.find_by_name(juicio.withoutgood_stage.name)
      nuevo_juicio.good_activity_id = 1
      nuevo_juicio.callback_skip = true
      respond_to do |format|
        if nuevo_juicio.save
          nuevo_juicio.update(created_at: juicio.created_at, updated_at: juicio.updated_at)
          juicio.destroy
          format.html{ redirect_to nuevo_juicio, notice: 'Se cambio el juicio exitosamente'}
        else
          format.html{ redirect_to root_path, notice: 'Algo salió mal! Intentalo de nuevo'}
        end
      end
    end
  end
end
