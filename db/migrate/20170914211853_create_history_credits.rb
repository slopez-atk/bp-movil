class CreateHistoryCredits < ActiveRecord::Migration[5.1]
  def change
    create_table :history_credits do |t|
      t.string :credit_id
      t.string :socio_id
      t.string :cedula
      t.string :agencia
      t.string :abogado
      t.string :asesor
      t.string :estado
      t.string :semaforo

      t.timestamps
    end
  end
end
