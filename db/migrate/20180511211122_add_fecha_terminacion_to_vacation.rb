class AddFechaTerminacionToVacation < ActiveRecord::Migration[5.1]
  def change
    add_column :vacations, :fecha_terminacion, :date
  end
end
