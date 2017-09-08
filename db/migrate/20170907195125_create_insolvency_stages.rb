class CreateInsolvencyStages < ActiveRecord::Migration[5.1]
  def change
    create_table :insolvency_stages do |t|
      t.string :name
      t.integer :months
      t.integer :days

      t.timestamps
    end
  end
end
