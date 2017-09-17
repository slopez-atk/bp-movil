class AddTipoCreditoToHistoryCredit < ActiveRecord::Migration[5.1]
  def change
    add_column :history_credits, :tipo_credito, :string
  end
end
