# == Schema Information
#
# Table name: insolvencies
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
#  insolvency_stage_id     :integer
#  insolvency_activity_id  :integer
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
#

require 'test_helper'

class InsolvencyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
