# == Schema Information
#
# Table name: goods
#
#  id                      :integer          not null, primary key
#  credit_id               :string
#  socio_id                :string
#  nombres                 :string
#  cedula                  :string
#  telefono                :string
#  celular                 :string
#  direccion               :string
#  sector                  :string
#  parroquia               :string
#  canton                  :string
#  nombre_grupo            :string
#  grupo_solidario         :string
#  sucursal                :string
#  oficial_credito         :string
#  cartera_heredada        :string
#  fecha_concesion         :string
#  fecha_vencimiento       :string
#  tipo_garantia           :string
#  garantia_real           :string
#  garantia_fiduciaria     :string
#  dir_garante             :string
#  tel_garante             :string
#  valor_cartera_castigada :string
#  bienes                  :string
#  tipo_credito            :string
#  good_stage_id           :integer
#  good_activity_id        :integer
#  estado                  :string
#  observaciones           :text
#  juicio_id               :string
#  fentrega_juicios        :date
#  fcalificacion_juicio    :date
#  codigo_juicio           :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  lawyer_id               :integer
#

class Good < ApplicationRecord
  belongs_to :good_stage
  belongs_to :good_activity
  belongs_to :lawyer
  after_create :delete_pending


  # Scopes
  scope :activos, -> { where(estado: "Activo") }
  scope :cancelados, -> { where(estado: "Cancelado") }
  scope :reingresos, -> { where(estado: "Reingreso") }
  scope :terminados, -> { where(estado: "Terminado") }
  scope :insolvencias, -> { where(estado: "Insolvencia") }
  scope :reestructurados, -> { where(estado: "Reestructurado") }
  scope :abandonados, -> { where(estado: "Abandono") }

  def etapa_estimada
    fecha_inicio = self.created_at.to_date
    dias_transcurridos = (Date.current - fecha_inicio)

    if dias_transcurridos >= ((fecha_inicio + 12.month) - fecha_inicio).to_i
      "Termina proceso"
    elsif dias_transcurridos >= ((fecha_inicio + 11.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 12.month) - fecha_inicio).to_i
      "Ejecución de remate"
    elsif dias_transcurridos >= ((fecha_inicio + 9.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 11.month) - fecha_inicio).to_i
      "Audiencia de ejecución"
    elsif dias_transcurridos >= ((fecha_inicio + 8.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 9.month) - fecha_inicio).to_i
      "Liquidación"
    elsif dias_transcurridos >= ((fecha_inicio + 7.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 8.month) - fecha_inicio).to_i
      "Sentencia"
    elsif dias_transcurridos >= ((fecha_inicio + 5.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 7.month) - fecha_inicio).to_i
      "Citaciones finalizadas - Razón"
    elsif dias_transcurridos >= ((fecha_inicio + 2.month) - fecha_inicio).to_i and dias_transcurridos <= ((fecha_inicio + 5.month) - fecha_inicio).to_i
      "Acta de sorteo judicial"
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
    mes = self.good_stage.months.to_i

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
      when "Acta de sorteo judicial"
        fecha_etapa_estimada = self.created_at + 2.month
        fecha_proxima_etapa =  self.created_at + 5.month
      when "Citaciones finalizadas - Razón"
        fecha_etapa_estimada = self.created_at + 5.month
        fecha_proxima_etapa =  self.created_at + 7.month
      when "Sentencia"
        fecha_etapa_estimada = self.created_at + 7.month
        fecha_proxima_etapa =  self.created_at + 8.month
      when "Liquidación"
        fecha_etapa_estimada = self.created_at + 8.month
        fecha_proxima_etapa =  self.created_at + 9.month
      when "Audiencia de ejecución"
        fecha_etapa_estimada = self.created_at + 9.month
        fecha_proxima_etapa =  self.created_at + 11.month
      when "Ejecución de remate"
        fecha_etapa_estimada = self.created_at + 11.month
        fecha_proxima_etapa =  self.created_at + 12.month
      when "Termina proceso"
        fecha_etapa_estimada = self.created_at + 12.month
        return ["terminado", "label label-default"]
    end
    # Si las etapas son iguales quiere decir que solo va a poder estar en rojo
    # o amarillo segun los días transcurrido entre las etapas
    if self.good_stage.name == nombre_etapa_estimada
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

      # Almacena los días que hay etapa actual hasta la estimada si es negativo
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

  def self.filtrar_creditos(creditos)
    r = Good.pluck(:credit_id)
    r +=Insolvency.pluck(:credit_id)
    r +=WithoutGood.pluck(:credit_id)
    r +=PendingTrial.pluck(:credit_id)

    ids_repetidos = Array.new
    creditos.each_with_index do |credit, i|
      # Encuentra y guarda en un array los id_credito repetidos
      if r.include?(credit["ID_CREDITO"])
        ids_repetidos.push(credit["ID_CREDITO"])
      end
    end

    ids_repetidos.each do |id|
      creditos = self.eliminar_de_array id,creditos
    end
    creditos
  end

  def self.eliminar_de_array(id, array)
    array.each_with_index do |credito, i|
      if credito["ID_CREDITO"] == id
        array.delete_at(i)
      end
    end
  end

  def delete_pending
    PendingTrial.find_by(credit_id: self.credit_id).destroy
  end
end
