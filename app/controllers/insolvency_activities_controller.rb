class InsolvencyActivitiesController < ApplicationController
  before_action :set_insolvency_activity, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, only: [:index, :show]

  # GET /insolvency_activities
  # GET /insolvency_activities.json
  def index
    @insolvency_activities = InsolvencyActivity.all
  end

  # GET /insolvency_activities/1
  # GET /insolvency_activities/1.json
  def show
  end

  # GET /insolvency_activities/new
  def new
    @insolvency_activity = InsolvencyActivity.new
    @insolvency_activity.insolvency_stage_id = params["insolvency_stage"]

    @activities = InsolvencyActivity.where(insolvency_stage_id: params["insolvency_stage"])
  end

  # GET /insolvency_activities/1/edit
  def edit
  end

  # POST /insolvency_activities
  # POST /insolvency_activities.json
  def create
    @insolvency_activity = InsolvencyActivity.new(insolvency_activity_params)

    respond_to do |format|
      if @insolvency_activity.save
        format.html { redirect_to stages_root_path, notice: 'Insolvency activity was successfully created.' }
        format.json { render :show, status: :created, location: @insolvency_activity }
      else
        format.html { render :new }
        format.json { render json: @insolvency_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insolvency_activities/1
  # PATCH/PUT /insolvency_activities/1.json
  def update
    respond_to do |format|
      if @insolvency_activity.update(insolvency_activity_params)
        format.html { redirect_to @insolvency_activity, notice: 'Insolvency activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @insolvency_activity }
      else
        format.html { render :edit }
        format.json { render json: @insolvency_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insolvency_activities/1
  # DELETE /insolvency_activities/1.json
  def destroy
    @insolvency_activity.destroy
    respond_to do |format|
      format.html { redirect_to insolvency_activities_url, notice: 'Insolvency activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insolvency_activity
      @insolvency_activity = InsolvencyActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insolvency_activity_params
      params.require(:insolvency_activity).permit(:name, :insolvency_stage_id)
    end

    def set_layout
      return "creditos_judiciales" if action_name == "new"
    end
end
