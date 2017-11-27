class AddUserIdToHistoryCredit < ActiveRecord::Migration[5.1]
  def change
    add_column :history_credits, :user_id, :integer
  end
end
