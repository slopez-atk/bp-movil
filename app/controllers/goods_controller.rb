class GoodsController < ApplicationController
  before_action :set_good, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, only: [:index, :edit, :new, :destroy]

  # GET /goods
  # GET /goods.json
  def index
    @goods = Good.all
  end

  # GET /goods/1
  # GET /goods/1.json
  def show
    # Recupera los datos variables de este id de credito desde la bdd Oracle
    # Filtro la letra "R" al principio de credit_id para saber  si el juicio
    # tiene un id de reingreso y busque las variables
    id = @good.credit_id
    if id[0] == "R"
      id = id[2..id.length]
    end
    @variables = Oracledb.getSaldos(id)
    @semaforo_actual = @good.semaforo
  end

  # GET /goods/new
  def new
    @good = Good.new
  end

  # GET /goods/1/edit
  def edit
  end

  # POST /goods
  # POST /goods.json
  def create
    @good = Good.new(good_params)

    respond_to do |format|
      if @good.save
        format.html { redirect_to @good, notice: 'Good was successfully created.' }
        format.json { render :show, status: :created, location: @good }
      else
        format.html { render :new }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /goods/1
  # PATCH/PUT /goods/1.json
  def update
    respond_to do |format|
      if @good.update(good_params)
        format.html { redirect_to @good, notice: 'Good was successfully updated.' }
        format.json { render :show, status: :ok, location: @good }
      else
        format.html { render :edit }
        format.json { render json: @good.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /goods/1
  # DELETE /goods/1.json
  def destroy
    @good.destroy
    respond_to do |format|
      format.html { redirect_to goods_url, notice: 'Good was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_good
      @good = Good.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def good_params
      params.require(:good).permit(:credit_id, :socio_id, :nombres, :cedula, :telefono, :celular, :direccion, :sector, :parroquia, :canton, :nombre_grupo, :grupo_solidario, :sucursal, :oficial_credito, :cartera_heredada, :fecha_concesion, :fecha_vencimiento, :tipo_garantia, :garantia_real, :garantia_fiduciaria, :dir_garante, :tel_garante, :valor_cartera_castigada, :bienes, :tipo_credito, :good_stage_id, :good_activity_id, :estado, :observaciones, :juicio_id, :fentrega_juicios, :fcalificacion_juicio, :codigo_juicio, :lawyer_id)
    end

  def set_layout
    return "creditos_judiciales" if action_name == "show"
    super
  end
end
