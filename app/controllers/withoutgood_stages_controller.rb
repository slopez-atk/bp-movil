class WithoutgoodStagesController < ApplicationController
  before_action :set_withoutgood_stage, only: [:show, :edit, :update, :destroy]

  # GET /withoutgood_stages
  # GET /withoutgood_stages.json
  def index
    @withoutgood_stages = WithoutgoodStage.all
  end

  # GET /withoutgood_stages/1
  # GET /withoutgood_stages/1.json
  def show
  end

  # GET /withoutgood_stages/new
  def new
    @withoutgood_stage = WithoutgoodStage.new
  end

  # GET /withoutgood_stages/1/edit
  def edit
  end

  # POST /withoutgood_stages
  # POST /withoutgood_stages.json
  def create
    @withoutgood_stage = WithoutgoodStage.new(withoutgood_stage_params)

    respond_to do |format|
      if @withoutgood_stage.save
        format.html { redirect_to @withoutgood_stage, notice: 'Withoutgood stage was successfully created.' }
        format.json { render :show, status: :created, location: @withoutgood_stage }
      else
        format.html { render :new }
        format.json { render json: @withoutgood_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /withoutgood_stages/1
  # PATCH/PUT /withoutgood_stages/1.json
  def update
    respond_to do |format|
      if @withoutgood_stage.update(withoutgood_stage_params)
        format.html { redirect_to @withoutgood_stage, notice: 'Withoutgood stage was successfully updated.' }
        format.json { render :show, status: :ok, location: @withoutgood_stage }
      else
        format.html { render :edit }
        format.json { render json: @withoutgood_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /withoutgood_stages/1
  # DELETE /withoutgood_stages/1.json
  def destroy
    @withoutgood_stage.destroy
    respond_to do |format|
      format.html { redirect_to withoutgood_stages_url, notice: 'Withoutgood stage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_withoutgood_stage
      @withoutgood_stage = WithoutgoodStage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def withoutgood_stage_params
      params.require(:withoutgood_stage).permit(:name, :months, :days)
    end
end
