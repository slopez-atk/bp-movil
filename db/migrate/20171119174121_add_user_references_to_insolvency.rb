class AddUserReferencesToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_reference :insolvencies, :user, foreign_key: true
    add_column :insolvencies, :valor_avaluo_comercial, :string
    add_column :insolvencies, :valor_avaluo_catastral, :string
    add_column :insolvencies, :avaluo_titulo, :string
    add_column :insolvencies, :interes, :string
    add_column :insolvencies, :mora, :string
    add_column :insolvencies, :gastos_judiciales, :string
  end
end
