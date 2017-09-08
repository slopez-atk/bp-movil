class CreateInsolvencyActivities < ActiveRecord::Migration[5.1]
  def change
    create_table :insolvency_activities do |t|
      t.string :name
      t.references :insolvency_stage, foreign_key: true

      t.timestamps
    end
  end
end
