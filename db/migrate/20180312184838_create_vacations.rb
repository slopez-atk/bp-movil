class CreateVacations < ActiveRecord::Migration[5.1]
  def change
    create_table :vacations do |t|
      t.references :worker, foreign_key: true
      t.date :fecha_permiso
      t.string :descripcion
      t.string :horas

      t.timestamps
    end
  end
end
