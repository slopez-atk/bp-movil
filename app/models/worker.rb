# == Schema Information
#
# Table name: workers
#
#  id            :integer          not null, primary key
#  fullname      :string
#  codigo        :string
#  agencia       :string
#  cargo         :string
#  fecha_ingreso :date
#  fecha_calculo :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Worker < ApplicationRecord
  has_many :vacations
  has_many :permission_histories

  def calcular_vacaciones
    fecha = self.fecha_calculo.to_date
    dias = (Date.current - fecha).to_i

    if dias > 365 && dias < 540
      dias2 = (Date.current - self.fecha_ingreso.to_date).to_i
      puts dias2
      if dias2 >= 1825
        [16,'rojo']
      else
        [15,'rojo']
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
    total = dias[0] * 8

    consumidos = self.calcular_horas_consumidos
    total - consumidos
  end
end
