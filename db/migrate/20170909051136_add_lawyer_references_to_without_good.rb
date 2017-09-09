class AddLawyerReferencesToWithoutGood < ActiveRecord::Migration[5.1]
  def change
    add_reference :without_goods, :lawyer, foreign_key: true
  end
end
