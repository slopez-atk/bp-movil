class WorkerPlanificationsController < ApplicationController
  before_action :set_worker_planification, only: [:show, :edit, :update, :destroy]
  before_action :set_worker, only: [:index, :create]
  before_action :authenticate_user!

  # GET /worker_planifications
  # GET /worker_planifications.json
  def index
    @worker_planifications = @worker.worker_planifications
    @planificaciones = @worker_planifications.as_json
    @planificaciones.each do |item|


      worker = Worker.find(item['worker_id'])

      item['fullname'] = worker['fullname']
      item['start_date'] = item['start_date'].to_date.strftime('%d-%m-%Y')
      item['end_date'] = item['end_date'].to_date.strftime('%d-%m-%Y')
    end
  end

  # GET /worker_planifications/1
  # GET /worker_planifications/1.json
  def show
  end

  # GET /worker_planifications/new
  def new
    @worker_planification = WorkerPlanification.new
  end

  # GET /worker_planifications/1/edit
  def edit
  end

  # POST /worker_planifications
  # POST /worker_planifications.json
  def create
    @worker_planification = @worker.worker_planifications.build(worker_planification_params)
    # @worker_planification = WorkerPlanification.new(worker_planification_params)

    respond_to do |format|
      if @worker_planification.save


        @worker_planifications = @worker.worker_planifications
        @planificaciones = @worker_planifications.as_json
        @planificaciones.each do |item|
          worker = Worker.find(item['worker_id'])

          item['fullname'] = worker['fullname']
          item['start_date'] = item['start_date'].to_date.strftime('%d-%m-%Y')
          item['end_date'] = item['end_date'].to_date.strftime('%d-%m-%Y')
        end
        format.html { redirect_to @worker_planification, :only_path => true, notice: 'Worker planification was successfully created.' }
        format.json { render json: @planificaciones, :layout => false}

      else
        format.html { render :new }
        format.json { render json: @worker_planification.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /worker_planifications/1
  # PATCH/PUT /worker_planifications/1.json
  def update
    respond_to do |format|
      if @worker_planification.update(worker_planification_params)
        format.html { redirect_to worker_planifications_path(id: @worker_planification.worker.id), notice: 'Datos actualizados!.' }
        format.json { render :show, status: :ok, location: @worker_planification }
      else
        format.html { render :edit }
        format.json { render json: @worker_planification.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /worker_planifications/1
  # DELETE /worker_planifications/1.json
  def destroy
    worker = @worker_planification.worker
    @worker_planification.destroy
    @planificaciones = worker.worker_planifications.as_json
    @planificaciones.each do |item|
      worker = Worker.find(item['worker_id'])

      item['fullname'] = worker['fullname']
      item['start_date'] = item['start_date'].to_date.strftime('%d-%m-%Y')
      item['end_date'] = item['end_date'].to_date.strftime('%d-%m-%Y')
    end

    respond_to do |format|
      format.html { redirect_to worker_planifications_path(id: worker.id), notice: 'Eliminacion exitosa.' }
      format.json { render json:  @planificaciones, :layout => false }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_worker_planification
      @worker_planification = WorkerPlanification.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def worker_planification_params
      params.require(:worker_planification).permit(:worker_id, :start_date, :end_date, :horas_estimadas)
    end

    def set_worker
      @worker = Worker.find(params[:id])
    end

    def set_layout
      return 'recursos_humanos'
    end
end
