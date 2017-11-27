class AddUserReferencesToWithoutGood < ActiveRecord::Migration[5.1]
  def change
    add_reference :without_goods, :user, foreign_key: true
    add_column :without_goods, :valor_avaluo_comercial, :string
    add_column :without_goods, :valor_avaluo_catastral, :string
    add_column :without_goods, :avaluo_titulo, :string
    add_column :without_goods, :interes, :string
    add_column :without_goods, :mora, :string
    add_column :without_goods, :gastos_judiciales, :string
  end
end
