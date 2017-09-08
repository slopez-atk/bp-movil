class GoodActivitiesController < ApplicationController
  before_action :set_good_activity, only: [:show, :edit, :update, :destroy]

  # GET /good_activities
  # GET /good_activities.json
  def index
    @good_activities = GoodActivity.all
  end

  # GET /good_activities/1
  # GET /good_activities/1.json
  def show
  end

  # GET /good_activities/new
  def new
    @good_activity = GoodActivity.new
  end

  # GET /good_activities/1/edit
  def edit
  end

  # POST /good_activities
  # POST /good_activities.json
  def create
    @good_activity = GoodActivity.new(good_activity_params)

    respond_to do |format|
      if @good_activity.save
        format.html { redirect_to @good_activity, notice: 'Good activity was successfully created.' }
        format.json { render :show, status: :created, location: @good_activity }
      else
        format.html { render :new }
        format.json { render json: @good_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /good_activities/1
  # PATCH/PUT /good_activities/1.json
  def update
    respond_to do |format|
      if @good_activity.update(good_activity_params)
        format.html { redirect_to @good_activity, notice: 'Good activity was successfully updated.' }
        format.json { render :show, status: :ok, location: @good_activity }
      else
        format.html { render :edit }
        format.json { render json: @good_activity.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /good_activities/1
  # DELETE /good_activities/1.json
  def destroy
    @good_activity.destroy
    respond_to do |format|
      format.html { redirect_to good_activities_url, notice: 'Good activity was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_good_activity
      @good_activity = GoodActivity.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def good_activity_params
      params.require(:good_activity).permit(:name, :good_stage_id)
    end
end
