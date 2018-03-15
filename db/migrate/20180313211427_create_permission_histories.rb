class CreatePermissionHistories < ActiveRecord::Migration[5.1]
  def change
    create_table :permission_histories do |t|
      t.references :worker, foreign_key: true
      t.string :descripcion
      t.string :fecha_permiso
      t.string :fecha_eliminacion
      t.string :horas

      t.timestamps
    end
  end
end
