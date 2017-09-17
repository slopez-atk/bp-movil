class AddFechaTerminadoToWithoutGoods < ActiveRecord::Migration[5.1]
  def change
    add_column :without_goods, :fecha_terminacion, :string
  end
end
