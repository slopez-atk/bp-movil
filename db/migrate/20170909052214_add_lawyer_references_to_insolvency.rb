class AddLawyerReferencesToInsolvency < ActiveRecord::Migration[5.1]
  def change
    add_reference :insolvencies, :lawyer, foreign_key: true
  end
end
