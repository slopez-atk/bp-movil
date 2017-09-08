class GoodStagesController < ApplicationController
  before_action :set_good_stage, only: [:show, :edit, :update, :destroy]

  # GET /good_stages
  # GET /good_stages.json
  def index
    @good_stages = GoodStage.all
  end

  # GET /good_stages/1
  # GET /good_stages/1.json
  def show
  end

  # GET /good_stages/new
  def new
    @good_stage = GoodStage.new
  end

  # GET /good_stages/1/edit
  def edit
  end

  # POST /good_stages
  # POST /good_stages.json
  def create
    @good_stage = GoodStage.new(good_stage_params)

    respond_to do |format|
      if @good_stage.save
        format.html { redirect_to @good_stage, notice: 'Good stage was successfully created.' }
        format.json { render :show, status: :created, location: @good_stage }
      else
        format.html { render :new }
        format.json { render json: @good_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /good_stages/1
  # PATCH/PUT /good_stages/1.json
  def update
    respond_to do |format|
      if @good_stage.update(good_stage_params)
        format.html { redirect_to @good_stage, notice: 'Good stage was successfully updated.' }
        format.json { render :show, status: :ok, location: @good_stage }
      else
        format.html { render :edit }
        format.json { render json: @good_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /good_stages/1
  # DELETE /good_stages/1.json
  def destroy
    @good_stage.destroy
    respond_to do |format|
      format.html { redirect_to good_stages_url, notice: 'Good stage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_good_stage
      @good_stage = GoodStage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def good_stage_params
      params.require(:good_stage).permit(:name, :months, :days)
    end
end
