class AddCalificacionToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_column :insolvencies, :calificacion, :string
  end
end
