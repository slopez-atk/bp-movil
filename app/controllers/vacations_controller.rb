class VacationsController < ApplicationController
  before_action :set_vacation, only: [:show, :edit, :update, :destroy]
  before_action :set_worker, only: [:new]
  before_action :authenticate_user!
  before_action :authenticate_permissions

  # GET /vacations
  # GET /vacations.json
  def index
    @vacations = Vacation.all
  end

  # GET /vacations/1
  # GET /vacations/1.json
  def show
  end

  # GET /vacations/new
  def new
    @vacation = @worker.vacations.new
    @vacation.worker_id = params[:id]
  end

  # GET /vacations/1/edit
  def edit
  end

  # POST /vacations
  # POST /vacations.json
  def create
    @vacation = Vacation.new(vacation_params)
    respond_to do |format|
      if @vacation.save
        format.html { redirect_to @vacation.worker, notice: 'Permiso creado satisfactoriamente!' }
        format.json { render :show, status: :created, location: @vacation }
      else
        format.html { render :new }
        format.json { render json: @vacation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vacations/1
  # PATCH/PUT /vacations/1.json
  def update
    respond_to do |format|
      if @vacation.update(vacation_params)
        format.html { redirect_to @vacation.worker, notice: 'Permiso actualizado satisfactoriamente!' }
        format.json { render :show, status: :ok, location: @vacation }
      else
        format.html { render :edit }
        format.json { render json: @vacation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vacations/1
  # DELETE /vacations/1.json
  def destroy
    worker = @vacation.worker
    @vacation.destroy
    respond_to do |format|
      format.html { redirect_to worker, notice: 'Vacation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vacation
      @vacation = Vacation.find(params[:id])
    end

    def set_worker
      @worker = Worker.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vacation_params
      params.require(:vacation).permit(:worker_id, :fecha_permiso, :descripcion, :horas)
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
