class AddFechaTerminadoToInsolvencies < ActiveRecord::Migration[5.1]
  def change
    add_column :insolvencies, :fecha_terminacion, :string
  end
end
