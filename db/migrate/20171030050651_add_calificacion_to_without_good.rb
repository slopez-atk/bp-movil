class AddCalificacionToWithoutGood < ActiveRecord::Migration[5.1]
  def change
    add_column :without_goods, :calificacion, :string
  end
end
