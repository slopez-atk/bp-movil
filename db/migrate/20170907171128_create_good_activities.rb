class CreateGoodActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :good_activities do |t|
      t.string :name
      t.references :good_stage, foreign_key: true

      t.timestamps
    end
  end
end
