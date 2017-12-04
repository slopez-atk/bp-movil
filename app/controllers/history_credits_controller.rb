class HistoryCreditsController < ApplicationController
  before_action :set_history_credit, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_gerente, only: [:eliminar]
  before_action :authenticate_user!
  before_action :authenticate_jcreditos, only: [:monitoreo, :store]
  before_action :authenticate_admin, only: [:index, :show, :new, :edit]

  def monitoreo
    @goods = Good.includes(:good_stage)
    @withoutgoods = WithoutGood.includes(:withoutgood_stage)
    @insolvencies = Insolvency.includes(:insolvency_stage)
    @fechas = HistoryCredit.obtener_fechas_guardadas
  end

  # Visualiza el historial de creditos
  def report
      if params["inicio"] == "" or params["fin"] == ""
        redirect_to creditos_root_path, notice: "Debes seleccionar dos fechas!"
        return false
      end

      fechainicio = params["inicio"]
      @inicio = fechainicio.to_date

      fechafin = params["fin"]
      @fin = fechafin.to_date

      # Guardo en un array los meses con los anios que queremos buscar
      @arreglo = extraer_fechas_entre(@inicio, @fin)

      @original = HistoryCredit.filtrado(@arreglo)

      if params["lawyer"].present?

        id_asesor = params[:user]["user_id"]
        if params["lawyer"]["full_name"] == ""; abogado = "%%" else abogado = params["lawyer"]["full_name"] end
        if params["asesores"] == ""; asesor = "%%" else asesor = params["asesores"] end
        if params["agencia"] == ""; agencia = "%%" else agencia = params["agencia"] end

        if id_asesor != ''
          @original = HistoryCredit.filtrado(@arreglo).abogado(abogado).asesor(asesor).agencia(agencia).asesores_cobranzas(id_asesor)
        else
          @original = HistoryCredit.filtrado(@arreglo).abogado(abogado).asesor(asesor).agencia(agencia)
        end

        @history_credits = @original.group(:credit_id, :id)

        if agencia == "%%"; agencia = "Todos" else agencia end
        if abogado == "%%"; abogado = "Todos" else abogado end
        if asesor == "%%"; asesor = "Todos" else agencia end

        if id_asesor != ''
          @filtros = {asesor: asesor, abogado: abogado, agencia: agencia, asesores_cobranzas: User.find(id_asesor).full_name}
        else
          @filtros = {asesor: asesor, abogado: abogado, agencia: agencia}
        end
      else
        @original = HistoryCredit.filtrado(@arreglo)
        @history_credits = @original.group(:credit_id, :id)
      end


  end

  # Metodo que guardar en la base de datos el historial de creditos
  def store
    @goods = Good.includes(:lawyer)
    @withoutgoods = WithoutGood.includes(:lawyer)
    @insolvencies = Insolvency.includes(:lawyer)

    date = 1.month.ago.strftime('%m-%Y')
    @goods.each do |credit|
      # Cancelados, abandonos
      if credit.estado == "Terminado" or credit.estado == "Abandono" or credit.estado == "Cancelado" or credit.estado == "Reestructurado"
        result = HistoryCredit.buscar_creditos_finalizados credit.credit_id
        if result.present?

        else
          semaforo = credit.semaforo
          HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "bienes")

        end
      else
        semaforo = credit.semaforo
        HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "bienes")
      end

    end

    @withoutgoods.each do |credit|
      if credit.estado == "Terminado" or credit.estado == "Abandono" or credit.estado == "Cancelado" or credit.estado == "Reestructurado"
        result = HistoryCredit.buscar_creditos_finalizados credit.credit_id
        if result.present?

        else
          semaforo = credit.semaforo
          HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "sinbienes")
        end
      else
        semaforo = credit.semaforo
        HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "sinbienes")

      end
    end

    @insolvencies.each do |credit|
      if credit.estado == "Terminado" or credit.estado == "Abandono" or credit.estado == "Cancelado" or credit.estado == "Reestructurado"
        result = HistoryCredit.buscar_creditos_finalizados credit.credit_id
        if result.present?

        else
          semaforo = credit.semaforo
          HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "insolvencia")
        end
      else
        semaforo = credit.semaforo
        HistoryCredit.create(credit_id: credit.credit_id, socio_id: credit.socio_id, cedula: credit.cedula, agencia: credit.sucursal, abogado: credit.lawyer.full_name, asesor: credit.oficial_credito, mes: date, estado: credit.estado, semaforo: semaforo[0], user_id: credit.user_id, tipo_credito: "insolvencia")

      end
    end

    respond_to do |format|
      format.html { redirect_to monitoreo_history_credits_path, notice: "Monitoreo guardado!" }
    end
  end

  # Elimina to-do el historial de creditos de una fecha dada
  def eliminar
    fecha = params[:fecha]
    HistoryCredit.find_by(mes: fecha)
    respond_to do |format|
      if HistoryCredit.where(mes: fecha).destroy_all
        format.html { redirect_to creditos_root_path, notice: "Se realizó la petición correctamente!" }
      else
        format.html { redirect_to creditos_root_path, alert: "Algo salio mal! Intentalo de nuevo"}
      end
    end
  end



  # GET /history_credits
  # GET /history_credits.json
  def index
    @history_credits = HistoryCredit.all
  end

  # GET /history_credits/1
  # GET /history_credits/1.json
  def show

  rescue ActiveRecord::RecordNotFound
    flash[:notice] = "No debes recargar esta página"
    redirect_to root_path
  end

  # GET /history_credits/new
  def new
    @history_credit = HistoryCredit.new
  end

  # GET /history_credits/1/edit
  def edit
  end

  # POST /history_credits
  # POST /history_credits.json
  def create
    @history_credit = HistoryCredit.new(history_credit_params)

    respond_to do |format|
      if @history_credit.save
        format.html { redirect_to @history_credit, notice: 'History credit was successfully created.' }
        format.json { render :show, status: :created, location: @history_credit }
      else
        format.html { render :new }
        format.json { render json: @history_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /history_credits/1
  # PATCH/PUT /history_credits/1.json
  def update
    respond_to do |format|
      if @history_credit.update(history_credit_params)
        format.html { redirect_to @history_credit, notice: 'History credit was successfully updated.' }
        format.json { render :show, status: :ok, location: @history_credit }
      else
        format.html { render :edit }
        format.json { render json: @history_credit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /history_credits/1
  # DELETE /history_credits/1.json
  def destroy
    @history_credit.destroy
    respond_to do |format|
      format.html { redirect_to history_credits_url, notice: 'History credit was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_history_credit
      @history_credit = HistoryCredit.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to creditos_root_path, notice: "No debes recargar esta página"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def history_credit_params
      params.require(:history_credit).permit(:credit_id, :socio_id, :cedula, :agencia, :abogado, :asesor, :estado, :semaforo)
    end

    # Convierte los paramatros(anio, mes, dia) a un tipo fecha 2017-03-25
    def convertir_fechas(anio, mes, dia)
      fecha = Date.new anio.to_i, mes.to_i, dia.to_i
    end

    # Extrae los meses-anios de las fechas de inicio y fin que se envian
    # por parametros y devulve un array ['07-2017', '09-2017']
    def extraer_fechas_entre(inicio, fin)
      arr = Array.new
      (inicio.year..fin.year).each do |y|
        mo_start = (inicio.year == y) ? inicio.month : 1
        mo_end = (fin.year == y) ? fin.month : 12


        (mo_start..mo_end).each do |m|
          fecha = Date.new(y,m,1).strftime('%m-%Y').to_s
          arr.push(fecha)
        end
      end
      arr
    end

    def set_layout
      return "creditos_judiciales" if action_name == "monitoreo" or action_name == "report"
    end

    def authenticate_gerente
      if current_user.permissions != 3
        redirect_to root_path, alert: "No estas autorizado"
        return false
      end
    end
end
