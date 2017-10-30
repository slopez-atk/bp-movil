class AddPropietarioBienesToWithoutGood < ActiveRecord::Migration[5.1]
  def change
    add_column :without_goods, :propietario_bienes, :string
  end
end
