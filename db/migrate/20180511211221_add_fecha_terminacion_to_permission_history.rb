class AddFechaTerminacionToPermissionHistory < ActiveRecord::Migration[5.1]
  def change
    add_column :permission_histories, :fecha_terminacion, :date
  end
end
