class AddPropietarioBienesToGood < ActiveRecord::Migration[5.1]
  def change
    add_column :goods, :propietario_bienes, :string
  end
end
