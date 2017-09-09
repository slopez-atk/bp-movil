# == Schema Information
#
# Table name: without_goods
#
#  id                       :integer          not null, primary key
#  credit_id                :string
#  socio_id                 :string
#  nombres                  :string
#  cedula                   :string
#  telefono                 :string
#  celular                  :string
#  direccion                :string
#  sector                   :string
#  parroquia                :string
#  canton                   :string
#  nombre_grupo             :string
#  grupo_solidario          :string
#  sucursal                 :string
#  oficial_credito          :string
#  cartera_heredada         :string
#  fecha_concesion          :string
#  fecha_vencimiento        :string
#  tipo_garantia            :string
#  garantia_real            :string
#  garantia_fiduciaria      :string
#  dir_garante              :string
#  tel_garante              :string
#  valor_cartera_castigada  :string
#  bienes                   :string
#  tipo_credito             :string
#  withoutgood_stage_id     :integer
#  without_good_activity_id :integer
#  estado                   :string
#  observaciones            :text
#  juicio_id                :string
#  fentrega_juicios         :date
#  fcalificacion_juicio     :date
#  codigo_juicio            :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class WithoutGood < ApplicationRecord
  belongs_to :withoutgood_stage
  belongs_to :without_good_activity
  belongs_to :lawyer


  def etapa_estimada
    fecha_inicio = self.created_at.to_date
    dias_transcurridos = (Date.current - fecha_inicio)
    # Compara que el # de días transcurridos estén entre el # días de inicio y fin de cada etapa
    if dias_transcurridos >= ((fecha_inicio + 8.month) - fecha_inicio).to_i
      "Liquidación"
    elsif dias_transcurridos >= ((fecha_inicio + 7.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 8.month) - fecha_inicio).to_i
      "Sentencia"
    elsif dias_transcurridos >= ((fecha_inicio + 5.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 7.month) - fecha_inicio).to_i
      "Citaciones finalizadas - razón"
    elsif dias_transcurridos >= ((fecha_inicio + 2.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 5.month) - fecha_inicio).to_i
      "Acta sorteo judicial"
    elsif dias_transcurridos >= ((fecha_inicio + 1.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 2.month) - fecha_inicio).to_i
      "Documentos habilitantes"
    else
      "Autorización proceso judicial"
    end

  end

  def semaforo
    # Alamacenará la fecha de la etapa estimada del credito
    fecha_etapa_estimada = ''

    # Almacenará la fecha de la proxima etapa la que viene despues de la estimada
    fecha_proxima_etapa = ''

    # Almacena el numero de mes de la etapa
    mes = self.withoutgood_stage.months.to_i

    # Almacena la fecha de la etapa actual en la que se encuentra el juicio
    fecha_etapa_actual = (self.created_at + mes.month).to_date

    nombre_etapa_estimada = self.etapa_estimada
    case nombre_etapa_estimada
      when "Autorización proceso judicial"
        fecha_etapa_estimada = self.created_at
        fecha_proxima_etapa =  self.created_at + 1.month
      when "Documentos habilitantes"
        fecha_etapa_estimada = self.created_at + 1.month
        fecha_proxima_etapa =  self.created_at + 2.month
      when "Acta sorteo judicial"
        fecha_etapa_estimada = self.created_at + 2.month
        fecha_proxima_etapa =  self.created_at + 5.month
      when "Citaciones finalizadas - razón"
        fecha_etapa_estimada = self.created_at + 5.month
        fecha_proxima_etapa =  self.created_at + 7.month
      when "Sentencia"
        fecha_etapa_estimada = self.created_at + 7.month
        fecha_proxima_etapa =  self.created_at + 8.month
      when "Liquidación"
        fecha_etapa_estimada = self.created_at + 8.month
        return ["terminado", "label label-default"]

    end
    # Si las etapas son iguales quiere decir que solo va a poder estar en rojo
    # o amarillo segun los días transcurrido entre las etapas
    if self.withoutgood_stage.name == nombre_etapa_estimada
      # Dias que han pasado desde la etapa hasta ahora
      dias_transcurridos = (Date.current - fecha_etapa_estimada.to_date).to_i
      # Dias totales que existe entre etapa y etapa para poder sacar el 25%
      dias_proxima_etapa = (fecha_proxima_etapa.to_date - fecha_etapa_estimada.to_date)
      # Quiere decir que aún no ha pasado o ya pasó los 0.4 días
      if dias_transcurridos <= (dias_proxima_etapa * 0.4).to_i
        ["verde", "label label-success"]
      else
        ["amarillo", "label label-warning"]
      end
    else # Si las etapas son diferentes quiere decir que o está atrasado o estado adelantado
      # Días que han pasado desde la fecha que empieza la etapa hasta ahora
      # si es negativo quiere decir que esta adelantado y se encuentra en una etapa a futuro
      dias_transcurridos_desde_etapa_actual = (Date.current - fecha_etapa_actual).to_i

      # Almacena los días que hay desde etapa actual hasta la estimada si es negativo
      # quiere decir que se encuentra  adelantado entre etapas
      dias_entre_etapas = (fecha_etapa_estimada.to_date - fecha_etapa_actual).to_i

      # Si los días que han transcurrido son mayores al numero total de días entre las etapas es
      # porque esta trasado una etapa, se valida que sean positivos porque cuando son negativos
      # quiere decir que esta adelantado
      if ( dias_transcurridos_desde_etapa_actual > dias_entre_etapas) and dias_entre_etapas > 0
        ["rojo", "label label-danger"]
      else
        ["verde", "label label-success"]
      end
    end
  end

end
