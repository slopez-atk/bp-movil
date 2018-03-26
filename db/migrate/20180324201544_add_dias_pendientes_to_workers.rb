class AddDiasPendientesToWorkers < ActiveRecord::Migration[5.1]
  def change
    add_column :workers, :dias_pendientes, :float, default: 0.0
  end
end
