class AddPropietarioBienesToPendingTrial < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_trials, :propietario_bienes, :string
  end
end
