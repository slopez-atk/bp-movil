# == Schema Information
#
# Table name: workers
#
#  id              :integer          not null, primary key
#  fullname        :string
#  codigo          :string
#  agencia         :string
#  cargo           :string
#  fecha_ingreso   :date
#  fecha_calculo   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  dias_pendientes :float            default(0.0)
#

class Worker < ApplicationRecord
  has_many :vacations
  has_many :permission_histories
  has_many :worker_planifications

  def calcular_vacaciones
    fecha = self.fecha_calculo.to_date
    dias = (Date.current - fecha).to_i

    if dias > 365 && dias < 540
      dias2 = (Date.current - self.fecha_ingreso.to_date).to_i

      anios = Date.current.year - self.fecha_ingreso.to_date.year
      anios = anios - 5
      if anios < 0
        [15,'rojo']
      elsif anios == 1
        [16,'rojo']
      elsif anios > 0
        if anios > 20
          [30,'rojo']
        else
          [anios + 15,'rojo']
        end
      end
    elsif dias < 330
      [0,'verde']
    elsif dias > 331 && dias < 365
      [0,'amarillo']
    else
      [15,'negro']
    end
  end

  def calcular_horas_consumidos
    total = 0
    self.vacations.each do |permiso|
      total += permiso.horas.to_i
    end
    total
  end

  def calculo_horas_restantes
    dias = self.calcular_vacaciones
    dias = dias[0].to_i + self.dias_pendientes # <= Dias Acumuladas
    total = dias * 8

    consumidos = self.calcular_horas_consumidos
    total - consumidos
  end
end
