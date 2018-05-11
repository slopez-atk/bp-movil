class PermissionHistoriesController < ApplicationController
  before_action :set_permission_history, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :set_worker, only: [:index]
  before_action :authenticate_permissions

  # GET /permission_histories
  # GET /permission_histories.json
  def index
    @permission_histories = @worker.permission_histories
  end

  # GET /permission_histories/1
  # GET /permission_histories/1.json
  def show
  end

  # GET /permission_histories/new
  def new
    @permission_history = PermissionHistory.new
  end

  # GET /permission_histories/1/edit
  def edit
  end

  # POST /permission_histories
  # POST /permission_histories.json
  def create
    @permission_history = PermissionHistory.new(permission_history_params)

    respond_to do |format|
      if @permission_history.save
        format.html { redirect_to @permission_history, notice: 'Permission history was successfully created.' }
        format.json { render :show, status: :created, location: @permission_history }
      else
        format.html { render :new }
        format.json { render json: @permission_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /permission_histories/1
  # PATCH/PUT /permission_histories/1.json
  def update
    respond_to do |format|
      if @permission_history.update(permission_history_params)
        format.html { redirect_to @permission_history, notice: 'Permission history was successfully updated.' }
        format.json { render :show, status: :ok, location: @permission_history }
      else
        format.html { render :edit }
        format.json { render json: @permission_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /permission_histories/1
  # DELETE /permission_histories/1.json
  def destroy
    @permission_history.destroy
    respond_to do |format|
      format.html { redirect_to permission_histories_url, notice: 'Permission history was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_permission_history
      @permission_history = PermissionHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def permission_history_params
      params.require(:permission_history).permit(:worker_id, :descripcion, :fecha_permiso, :fecha_eliminacion, :horas, :fecha_terminacion)
    end

    def set_worker
      @worker = Worker.find(params[:id])
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
