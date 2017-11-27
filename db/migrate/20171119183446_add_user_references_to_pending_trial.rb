class AddUserReferencesToPendingTrial < ActiveRecord::Migration[5.1]
  def change
    add_reference :pending_trials, :user, foreign_key: true
    add_column :pending_trials, :valor_avaluo_comercial, :string
    add_column :pending_trials, :valor_avaluo_catastral, :string
    add_column :pending_trials, :avaluo_titulo, :string
    add_column :pending_trials, :interes, :string
    add_column :pending_trials, :mora, :string
    add_column :pending_trials, :gastos_judiciales, :string
  end
end
