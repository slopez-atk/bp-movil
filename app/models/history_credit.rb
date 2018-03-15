# == Schema Information
#
# Table name: history_credits
#
#  id           :integer          not null, primary key
#  credit_id    :string
#  socio_id     :string
#  cedula       :string
#  agencia      :string
#  abogado      :string
#  asesor       :string
#  estado       :string
#  semaforo     :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mes          :string
#  tipo_credito :string
#  user_id      :integer
#

class HistoryCredit < ApplicationRecord
  # Me permite recuperar unicamente el historial entre las fechas dadas
  # la variable fechas es un array
  scope :filtrado, ->(fechas) { where(mes: fechas) }
  scope :verdes, ->{ where(estado: "Verde") }
  scope :amarillos, ->{ where(estado: "Amarillo") }
  scope :rojos, ->{ where(estado: "Rojo") }
  scope :activos, ->{ where(estado: "Activo") }

  scope :abogado, ->(nombres){where("abogado LIKE ?", "%#{nombres}%")}
  scope :agencia, ->(agencia){where("agencia LIKE ?", "#{agencia}")}
  scope :asesor, ->(asesor){where("asesor LIKE ?", "#{asesor}")}

  scope :asesores_cobranzas, ->(id){where(user_id: id)}

  # Recibe un id_credito, un mes y todos los datos
  # y regresa el valor del semaforo
  def self.buscar_fecha(id_credito, fecha, datos)
    datos.each do | row |
      if row.credit_id == id_credito && row.mes == fecha
        return row.semaforo
      end
    end
    return nil
  end

  # Buscara en los historiales de credito si un credito terminado, abandonado o terminado ya se ingreso
  # para no ingresarlo dos veces
  def self.buscar_creditos_finalizados(credit_id)
    results = HistoryCredit.where(credit_id: credit_id).where(estado: ["Terminado", "Abandono", "Cancelado"])
    if results.present?
       results
    else
       nil
    end
  end

  def self.obtener_fechas_guardadas
    HistoryCredit.distinct.pluck(:mes)
  end

  def self.obtener_agencias
    HistoryCredit.distinct.pluck(:agencia)
  end

  def self.obtener_asesores
    HistoryCredit.distinct.pluck(:asesor)
  end

end
