class AddColumnsToPendingTrial < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_trials, :calificacion_propia, :string
  end
end
