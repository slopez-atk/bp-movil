class AddColumnsToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_column :insolvencies, :nom_garante1, :string
    add_column :insolvencies, :ci_garante_1, :string
    add_column :insolvencies, :cony_garante1, :string
    add_column :insolvencies, :nom_garante2, :string
    add_column :insolvencies, :ci_garante2, :string
    add_column :insolvencies, :cony_garante2, :string
  end
end
