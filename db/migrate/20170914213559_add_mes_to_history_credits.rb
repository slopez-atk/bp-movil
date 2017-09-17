class AddMesToHistoryCredits < ActiveRecord::Migration[5.1]
  def change
    add_column :history_credits, :mes, :string
  end
end
