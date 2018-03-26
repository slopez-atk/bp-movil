class RecursosHumanosController < ApplicationController
  before_action :set_worker, only: [:guardar_historial]
  before_action :authenticate_user!
  before_action :authenticate_permissions

  def index
  end

  def vacaciones
    @workers = Worker.order(:agencia => :asc, :fullname => :asc)
  end

  def planificacion_general
    @planificaciones = WorkerPlanification.all.as_json
    @planificaciones.each do |item|
      worker = Worker.find(item['worker_id'])
      item['fullname'] = worker['fullname'] + " - " + worker['agencia']
      item['start_date'] = item['start_date'].to_date.strftime('%d-%m-%Y')
      item['end_date'] = item['end_date'].to_date.strftime('%d-%m-%Y')
    end
  end

  def guardar_historial
    @worker.vacations.each do |permission|
      history = @worker.permission_histories.build(permission.as_json.to_h.except!("id"))
      history.fecha_eliminacion = Date.current
      history.save
    end

    nueva_fecha = @worker.fecha_calculo.to_date + 365.day
    horas_restantes = (@worker.calculo_horas_restantes.to_f / 8.0).round(1) + @worker.dias_pendientes
    @worker.update(fecha_calculo: nueva_fecha, dias_pendientes: horas_restantes)
    @worker.vacations.destroy_all
    @worker.worker_planifications.destroy_all
    redirect_to @worker, notice: "Permisos del empleado #{@worker.fullname} actualizados"

  end

  private

  def set_layout
    return "recursos_humanos"
    super
  end

  def set_worker
    @worker = Worker.find(params[:id])
  end

  def authenticate_permissions
    unless current_user.permissions == 10 || current_user.permissions == 9 || current_user.permissions == 3
      redirect_to root_path, notice: "No estas autorizado!"
    end
  end
end