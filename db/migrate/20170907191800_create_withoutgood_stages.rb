class CreateWithoutgoodStages < ActiveRecord::Migration[5.1]
  def change
    create_table :withoutgood_stages do |t|
      t.string :name
      t.integer :months
      t.integer :days

      t.timestamps
    end
  end
end
