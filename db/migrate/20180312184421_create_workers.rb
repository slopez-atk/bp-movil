class CreateWorkers < ActiveRecord::Migration[5.1]
  def change
    create_table :workers do |t|
      t.string :fullname
      t.string :codigo
      t.string :agencia
      t.string :cargo
      t.date :fecha_ingreso
      t.string :fecha_calculo

      t.timestamps
    end
  end
end
