class AddColumnToWithoutGoods < ActiveRecord::Migration[5.1]
  def change
    add_column :without_goods, :fecha_original_juicio, :date
  end
end
