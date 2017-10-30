class AddGarantesToPendingTrial < ActiveRecord::Migration[5.1]
  def change
    add_column :pending_trials, :nom_garante1, :string
    add_column :pending_trials, :ci_garante_1, :string
    add_column :pending_trials, :cony_garante1, :string
    add_column :pending_trials, :nom_garante2, :string
    add_column :pending_trials, :ci_garante2, :string
    add_column :pending_trials, :cony_garante2, :string
  end
end
