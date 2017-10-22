class AddColumnToGoods < ActiveRecord::Migration[5.1]
  def change
    add_column :goods, :fecha_original_juicio, :date
  end
end
