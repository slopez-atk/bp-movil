class InsolvenciesController < ApplicationController
  before_action :set_insolvency, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, only: [:index, :edit, :new, :destroy]

  # GET /insolvencies
  # GET /insolvencies.json
  def index
    @insolvencies = Insolvency.all
  end

  # GET /insolvencies/1
  # GET /insolvencies/1.json
  def show
    # Recupera los datos variables de este id de credito desde la bdd Oracle
    # Filtro la letra "R" al principio de credit_id para saber  si el juicio
    # tiene un id de reingreso y busque las variables
    id = @insolvency.credit_id
    if id[0] == "R" or id[0] == "I"
      id = id[2..id.length]
    end
    @variables = Oracledb.getSaldos(id)
    @semaforo_actual = @insolvency.semaforo
  end

  # GET /insolvencies/new
  def new
    @insolvency = Insolvency.new
  end

  # GET /insolvencies/1/edit
  def edit
  end

  # POST /insolvencies
  # POST /insolvencies.json
  def create
    @insolvency = Insolvency.new(insolvency_params)

    respond_to do |format|
      if @insolvency.save
        format.html { redirect_to @insolvency, notice: 'Insolvency was successfully created.' }
        format.json { render :show, status: :created, location: @insolvency }
      else
        format.html { render :new }
        format.json { render json: @insolvency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insolvencies/1
  # PATCH/PUT /insolvencies/1.json
  def update
    respond_to do |format|
      if @insolvency.update(insolvency_params)
        format.html { redirect_to @insolvency, notice: 'Insolvency was successfully updated.' }
        format.json { render :show, status: :ok, location: @insolvency }
      else
        format.html { render :edit }
        format.json { render json: @insolvency.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insolvencies/1
  # DELETE /insolvencies/1.json
  def destroy
    @insolvency.destroy
    respond_to do |format|
      format.html { redirect_to insolvencies_url, notice: 'Insolvency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insolvency
      @insolvency = Insolvency.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insolvency_params
      params.require(:insolvency).permit(:credit_id, :socio_id, :nombres, :cedula, :telefono, :celular, :direccion, :sector, :parroquia, :canton, :nombre_grupo, :grupo_solidario, :sucursal, :oficial_credito, :cartera_heredada, :fecha_concesion, :fecha_vencimiento, :tipo_garantia, :garantia_real, :garantia_fiduciaria, :dir_garante, :tel_garante, :valor_cartera_castigada, :bienes, :tipo_credito, :insolvency_stage_id, :insolvency_activity_id, :estado, :observaciones, :juicio_id, :fentrega_juicios, :fcalificacion_juicio, :codigo_juicio, :lawyer_id)
    end

    def set_layout
      return "creditos_judiciales" if action_name == "show"
      super
    end
end
