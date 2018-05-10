class WorkersController < ApplicationController
  before_action :set_worker, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_permissions

  # GET /workers
  # GET /workers.json
  def index
    @workers = Worker.all
  end

  # GET /workers/1
  # GET /workers/1.json
  def show
    @dias_vigentes = @worker.calcular_vacaciones
    @horas_restantes = @worker.calculo_horas_restantes

    @vacations = @worker.vacations
  end

  # GET /workers/new
  def new
    @worker = Worker.new
    @vacations = @worker.vacations
  end

  # GET /workers/1/edit
  def edit
  end

  # POST /workers
  # POST /workers.json
  def create
    @worker = Worker.new(worker_params)

    respond_to do |format|
      if @worker.save
        format.html { redirect_to recursos_humanos_vacaciones_path, notice: 'Empleado ingresado satisfactoriamenete!' }
        format.json { render :show, status: :created, location: @worker }
      else
        format.html { render :new }
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /workers/1
  # PATCH/PUT /workers/1.json
  def update
    respond_to do |format|
      if @worker.update(worker_params)
        format.html { redirect_to @worker, notice: 'Empleado actualizado con exito!' }
        format.json { render :show, status: :ok, location: @worker }
      else
        format.html { render :edit }
        format.json { render json: @worker.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /workers/1
  # DELETE /workers/1.json
  def destroy
    @worker.destroy
    respond_to do |format|
      format.html { redirect_to workers_url, notice: 'Worker was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_worker
      @worker = Worker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worker_params
      params.require(:worker).permit(:fullname, :codigo, :agencia, :cargo, :fecha_ingreso, :fecha_calculo, :dias_pendientes)
    end

    def set_layout
      return "recursos_humanos"
    end

  def authenticate_permissions
    unless current_user.permissions == 10 || current_user.permissions == 9 || current_user.permissions == 3
      redirect_to root_path, notice: "No estas autorizado!"
    end
  end
end
