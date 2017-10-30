class AddColumnsToGood < ActiveRecord::Migration[5.1]
  def change
    add_column :goods, :nom_garante1, :string
    add_column :goods, :ci_garante_1, :string
    add_column :goods, :cony_garante1, :string
    add_column :goods, :nom_garante2, :string
    add_column :goods, :ci_garante2, :string
    add_column :goods, :cony_garante2, :string
  end
end
