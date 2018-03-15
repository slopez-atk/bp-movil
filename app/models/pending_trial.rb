# == Schema Information
#
# Table name: pending_trials
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
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  calificacion_propia     :string
#  nom_garante1            :string
#  ci_garante_1            :string
#  cony_garante1           :string
#  nom_garante2            :string
#  ci_garante2             :string
#  cony_garante2           :string
#  propietario_bienes      :string
#  calificacion            :string
#  user_id                 :integer
#  valor_avaluo_comercial  :string
#  valor_avaluo_catastral  :string
#  avaluo_titulo           :string
#  interes                 :string
#  mora                    :string
#  gastos_judiciales       :string
#

class PendingTrial < ApplicationRecord

  validates_presence_of :user_id
  belongs_to :user

  def self.pending_trials_count
    PendingTrial.count
  end

  def self.split_separado_por_comas arreglo
    cadena = ""
    if arreglo.nil?
      return ""
    end
    arreglo.each do |palabra|
      cadena += palabra + ","
    end
    cadena = cadena[0..-2]
  end
end
