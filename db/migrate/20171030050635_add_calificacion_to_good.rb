class AddCalificacionToGood < ActiveRecord::Migration[5.1]
  def change
    add_column :goods, :calificacion, :string
  end
end
