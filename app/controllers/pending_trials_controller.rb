class PendingTrialsController < ApplicationController
  before_action :set_pending_trial, only: [:show, :edit, :update, :destroy, :new]
  before_action :authenticate_user!

  # GET /pending_trials
  # GET /pending_trials.json
  def index
    @pending_trials = current_user.pending_trials
  end

  # GET /pending_trials/1
  # GET /pending_trials/1.json
  def show
    # Recupera los datos variables de este id de credito desde la bdd Oracle
    @variables = Oracledb.getSaldos(@pending_trial.credit_id)
  end

  #GET /pending_trials/new
  # Controlador modificado para poder crear un Juicio Con Bienes o Sin Bienes
  # apartir de un pending_trial
  def new

  end

  # POST /pending_trials
  # POST /pending_trials.json
  def create

    respond_to do |format|
      if params["setting"]["flag_bienes"] == "SI"
        @good = current_user.goods.new(pending_trial_params)
        @good.good_stage_id = 1
        @good.lawyer_id = params["lawyer"]["lawyer_id"]
        @good.good_activity_id = 1
        @good.estado = "Activo"

        @good.bienes = PendingTrial.split_separado_por_comas(params["pending_trial"]["bienes"])
        @good.propietario_bienes = PendingTrial.split_separado_por_comas(params["pending_trial"]["propietario_bienes"])

        if @good.save
          format.html { redirect_to creditos_root_path, notice: 'Juicio ingresado' }
        else
          format.html { redirect_to new_pending_trial_path(id:params["setting"]["id"]), notice: 'Asegurate de escoger un abogado'}

        end
      else
        @withoutgood = current_user.without_goods.new(pending_trial_params)
        @withoutgood.withoutgood_stage_id = 1
        @withoutgood.lawyer_id = params["lawyer"]["lawyer_id"]
        @withoutgood.without_good_activity_id = 1
        @withoutgood.estado = "Activo"

        @withoutgood.bienes = PendingTrial.split_separado_por_comas(params["pending_trial"]["bienes"])
        @withoutgood.propietario_bienes = PendingTrial.split_separado_por_comas(params["pending_trial"]["propietario_bienes"])

        if @withoutgood.save
          format.html { redirect_to creditos_root_path, notice: 'Juicio ingresado' }
        else
          format.html { redirect_to new_pending_trial_path(id:params["setting"]["id"]), notice: 'Asegurate de escoger un abogado'}

        end
      end
    end

  end


  # DELETE /pending_trials/1
  # DELETE /pending_trials/1.json
  def destroy
    @pending_trial.destroy
    respond_to do |format|
      format.html { redirect_to pending_trials_url, notice: 'Pending trial was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_pending_trial
      @pending_trial = PendingTrial.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def pending_trial_params
      params.require(:pending_trial).permit(:credit_id, :socio_id, :nombres, :cedula, :telefono, :celular, :direccion, :sector, :parroquia, :canton, :nombre_grupo, :grupo_solidario, :sucursal, :oficial_credito, :cartera_heredada, :fecha_concesion, :fecha_vencimiento, :tipo_garantia, :garantia_real, :garantia_fiduciaria, :dir_garante, :tel_garante, :valor_cartera_castigada, :bienes, :tipo_credito, :flag_bienes, :nom_garante1, :nom_garante2, :cony_garante1, :cony_garante2, :ci_garante_1, :ci_garante2, :propietario_bienes)
    end

    def set_layout
      return "creditos_judiciales" if action_name == "index" or action_name == "show" or action_name == "new"
    end
end
