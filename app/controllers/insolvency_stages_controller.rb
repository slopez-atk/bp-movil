class InsolvencyStagesController < ApplicationController
  before_action :set_insolvency_stage, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!
  before_action :authenticate_admin, only: [:index, :show]

  # GET /insolvency_stages
  # GET /insolvency_stages.json
  def index
    @insolvency_stages = InsolvencyStage.all
  end

  # GET /insolvency_stages/1
  # GET /insolvency_stages/1.json
  def show
  end

  # GET /insolvency_stages/new
  def new
    @insolvency_stage = InsolvencyStage.new
  end

  # GET /insolvency_stages/1/edit
  def edit
  end

  # POST /insolvency_stages
  # POST /insolvency_stages.json
  def create
    @insolvency_stage = InsolvencyStage.new(insolvency_stage_params)

    respond_to do |format|
      if @insolvency_stage.save
        format.html { redirect_to @insolvency_stage, notice: 'Insolvency stage was successfully created.' }
        format.json { render :show, status: :created, location: @insolvency_stage }
      else
        format.html { render :new }
        format.json { render json: @insolvency_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insolvency_stages/1
  # PATCH/PUT /insolvency_stages/1.json
  def update
    respond_to do |format|
      if @insolvency_stage.update(insolvency_stage_params)
        format.html { redirect_to @insolvency_stage, notice: 'Insolvency stage was successfully updated.' }
        format.json { render :show, status: :ok, location: @insolvency_stage }
      else
        format.html { render :edit }
        format.json { render json: @insolvency_stage.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insolvency_stages/1
  # DELETE /insolvency_stages/1.json
  def destroy
    @insolvency_stage.destroy
    respond_to do |format|
      format.html { redirect_to insolvency_stages_url, notice: 'Insolvency stage was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insolvency_stage
      @insolvency_stage = InsolvencyStage.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insolvency_stage_params
      params.require(:insolvency_stage).permit(:name, :months, :days)
    end
end
