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
#  fecha_terminacion       :string
#  fecha_original_juicio   :date
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

require 'test_helper'

class GoodTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
