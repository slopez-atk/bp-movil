class AddLawyerReferencesToGood < ActiveRecord::Migration[5.1]
  def change
    add_reference :goods, :lawyer, foreign_key: true
  end
end
