class AddColumnsToWithoutGood < ActiveRecord::Migration[5.1]
  def change
    add_column :without_goods, :nom_garante1, :string
    add_column :without_goods, :ci_garante_1, :string
    add_column :without_goods, :cony_garante1, :string
    add_column :without_goods, :nom_garante2, :string
    add_column :without_goods, :ci_garante2, :string
    add_column :without_goods, :cony_garante2, :string
  end
end
