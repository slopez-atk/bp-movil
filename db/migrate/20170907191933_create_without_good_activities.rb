class CreateWithoutGoodActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :without_good_activities do |t|
      t.string :name
      t.references :withoutgood_stage, foreign_key: true

      t.timestamps
    end
  end
end
