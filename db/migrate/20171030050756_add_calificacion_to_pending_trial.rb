class AddCalificacionToPendingTrial < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_trials, :calificacion, :string
  end
end
