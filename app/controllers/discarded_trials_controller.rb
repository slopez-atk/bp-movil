class DiscardedTrialsController < ApplicationController
  def destroy
    juicio = DiscardedTrial.find(params["id"])
    juicio.destroy
    respond_to do |format|
      format.html { redirect_to new_trials_root_path, notice: 'El Juicio se activo nuevamente!' }
    end
  end

  def ingresar
    id = params["id_credito"]
    juicio = DiscardedTrial.new(juicio_id: id)
    respond_to do |format|
      if juicio.save
        format.html { redirect_to new_trials_root_path, notice: 'Se descartó el juicio exitosamente!' }
      else
        format.html { redirect_to new_trials_root_path, notice: 'Algo salió mal intentalo nuevamente!' }
      end
    end
  end
end