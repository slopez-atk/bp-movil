class AddColumnToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_column :insolvencies, :fecha_original_juicio, :date
  end
end
