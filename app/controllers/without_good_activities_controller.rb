class WithoutGoodActivitiesController < ApplicationController
  before_action :set_without_good_activity, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, only: [:index, :show]

  # GET /without_good_activities
  # GET /without_good_activities.json
  def index
    @without_good_activities = WithoutGoodActivity.all
  end

  # GET /without_good_activities/1
  # GET /without_good_activities/1.json
  def show
  end

  # GET /without_good_activities/new
  def new
    @without_good_activity = WithoutGoodActivity.new
    @without_good_activity.withoutgood_stage_id = params["withoutgood_stage"]

    @activities = WithoutGoodActivity.where(withoutgood_stage_id: params["withoutgood_stage"])
  end

  # GET /without_good_activities/1/edit
  def edit
  end

  # POST /without_good_activities
  # POST /without_good_activities.json
  def create
    @without_good_activity = WithoutGoodActivity.new(without_good_activity_params)

    respond_to do |format|
      if @without_good_activity.save
        format.html { redirect_to stages_root_path, notice: 'Without good activity was successfully created.' }
        format.json { render :show, status: :created, location: @without_good_activity }
      else
        format.html { render :new }
        format.json { render json: @without_good_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /without_good_activities/1
  # PATCH/PUT /without_good_activities/1.json
  def update
    respond_to do |format|
      if @without_good_activity.update(without_good_activity_params)
        format.html { redirect_to @without_good_activity, notice: 'Without good activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @without_good_activity }
      else
        format.html { render :edit }
        format.json { render json: @without_good_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /without_good_activities/1
  # DELETE /without_good_activities/1.json
  def destroy
    @without_good_activity.destroy
    respond_to do |format|
      format.html { redirect_to without_good_activities_url, notice: 'Without good activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_without_good_activity
      @without_good_activity = WithoutGoodActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def without_good_activity_params
      params.require(:without_good_activity).permit(:name, :withoutgood_stage_id)
    end

    def set_layout
      return "creditos_judiciales" if action_name == "new"
    end
end
