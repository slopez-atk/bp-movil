class WithoutGoodsController < ApplicationController
  before_action :set_without_good, only: [:show, :edit, :update, :destroy]

  # GET /without_goods
  # GET /without_goods.json
  def index
    @without_goods = WithoutGood.all
  end

  # GET /without_goods/1
  # GET /without_goods/1.json
  def show
    # Recupera los datos variables de este id de credito desde la bdd Oracle
    @variables = Oracledb.getVariables(@without_good.credit_id).to_a
  end

  # GET /without_goods/new
  def new
    @without_good = WithoutGood.new
  end

  # GET /without_goods/1/edit
  def edit
  end

  # POST /without_goods
  # POST /without_goods.json
  def create
    @without_good = WithoutGood.new(without_good_params)

    respond_to do |format|
      if @without_good.save
        format.html { redirect_to @without_good, notice: 'Without good was successfully created.' }
        format.json { render :show, status: :created, location: @without_good }
      else
        format.html { render :new }
        format.json { render json: @without_good.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /without_goods/1
  # PATCH/PUT /without_goods/1.json
  def update
    respond_to do |format|
      if @without_good.update(without_good_params)
        format.html { redirect_to @without_good, notice: 'Without good was successfully updated.' }
        format.json { render :show, status: :ok, location: @without_good }
      else
        format.html { render :edit }
        format.json { render json: @without_good.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /without_goods/1
  # DELETE /without_goods/1.json
  def destroy
    @without_good.destroy
    respond_to do |format|
      format.html { redirect_to without_goods_url, notice: 'Without good was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_without_good
      @without_good = WithoutGood.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def without_good_params
      params.require(:without_good).permit(:credit_id, :socio_id, :nombres, :cedula, :telefono, :celular, :direccion, :sector, :parroquia, :canton, :nombre_grupo, :grupo_solidario, :sucursal, :oficial_credito, :cartera_heredada, :fecha_concesion, :fecha_vencimiento, :tipo_garantia, :garantia_real, :garantia_fiduciaria, :dir_garante, :tel_garante, :valor_cartera_castigada, :bienes, :tipo_credito, :withoutgood_stage_id, :without_good_activity_id, :estado, :observaciones, :juicio_id, :fentrega_juicios, :fcalificacion_juicio, :codigo_juicio)
    end

    def set_layout
      return "creditos_judiciales" if action_name == "show"
      super
    end
end
