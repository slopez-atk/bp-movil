class LawyersController < ApplicationController
  before_action :set_lawyer, only: [:show, :edit, :update, :destroy]

  # GET /lawyers
  # GET /lawyers.json
  def index
    @lawyers = Lawyer.all
  end

  # GET /lawyers/1
  # GET /lawyers/1.json
  def show
  end

  # GET /lawyers/new
  def new
    @lawyer = Lawyer.new
  end

  # GET /lawyers/1/edit
  def edit
  end

  # POST /lawyers
  # POST /lawyers.json
  def create
    @lawyer = Lawyer.new(lawyer_params)

    respond_to do |format|
      if @lawyer.save
        format.html { redirect_to @lawyer, notice: 'Lawyer was successfully created.' }
        format.json { render :show, status: :created, location: @lawyer }
      else
        format.html { render :new }
        format.json { render json: @lawyer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lawyers/1
  # PATCH/PUT /lawyers/1.json
  def update
    respond_to do |format|
      if @lawyer.update(lawyer_params)
        format.html { redirect_to @lawyer, notice: 'Lawyer was successfully updated.' }
        format.json { render :show, status: :ok, location: @lawyer }
      else
        format.html { render :edit }
        format.json { render json: @lawyer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lawyers/1
  # DELETE /lawyers/1.json
  def destroy
    @lawyer.destroy
    respond_to do |format|
      format.html { redirect_to lawyers_url, notice: 'Lawyer was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lawyer
      @lawyer = Lawyer.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lawyer_params
      params.require(:lawyer).permit(:name, :lastname, :phone)
    end
end
