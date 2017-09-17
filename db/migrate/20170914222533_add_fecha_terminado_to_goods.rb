class AddFechaTerminadoToGoods < ActiveRecord::Migration[5.1]
  def change
    add_column :goods, :fecha_terminacion, :string
  end
end
