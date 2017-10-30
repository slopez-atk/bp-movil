class AddPropietarioBienesToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_column :insolvencies, :propietario_bienes, :string
  end
end
