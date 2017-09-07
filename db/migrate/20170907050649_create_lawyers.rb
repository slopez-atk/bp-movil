class CreateLawyers < ActiveRecord::Migration[5.1]
  def change
    create_table :lawyers do |t|
      t.string :name
      t.string :lastname
      t.string :phone

      t.timestamps
    end
  end
end
