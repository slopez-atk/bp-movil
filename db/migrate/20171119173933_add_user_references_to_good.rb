class AddUserReferencesToGood < ActiveRecord::Migration[5.1]
  def change
    add_reference :goods, :user, foreign_key: true
    add_column :goods, :valor_avaluo_comercial, :string
    add_column :goods, :valor_avaluo_catastral, :string
    add_column :goods, :avaluo_titulo, :string
    add_column :goods, :interes, :string
    add_column :goods, :mora, :string
    add_column :goods, :gastos_judiciales, :string
  end
end
