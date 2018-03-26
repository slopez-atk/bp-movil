class CreateWorkerPlanifications < ActiveRecord::Migration[5.1]
  def change
    create_table :worker_planifications do |t|
      t.references :worker, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :horas_estimadas

      t.timestamps
    end
  end
end
