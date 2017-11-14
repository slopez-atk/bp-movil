class CreateDiscardedTrials < ActiveRecord::Migration[5.1]
  def change
    create_table :discarded_trials do |t|
      t.string :juicio_id

      t.timestamps
    end
  end
end
