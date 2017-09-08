require 'test_helper'

class GoodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @good = goods(:one)
  end

  test "should get index" do
    get goods_url
    assert_response :success
  end

  test "should get new" do
    get new_good_url
    assert_response :success
  end

  test "should create good" do
    assert_difference('Good.count') do
      post goods_url, params: { good: { bienes: @good.bienes, canton: @good.canton, cartera_heredada: @good.cartera_heredada, cedula: @good.cedula, celular: @good.celular, codigo_juicio: @good.codigo_juicio, credit_id: @good.credit_id, dir_garante: @good.dir_garante, direccion: @good.direccion, estado: @good.estado, fcalificacion_juicio: @good.fcalificacion_juicio, fecha_concesion: @good.fecha_concesion, fecha_vencimiento: @good.fecha_vencimiento, fentrega_juicios: @good.fentrega_juicios, garantia_fiduciaria: @good.garantia_fiduciaria, garantia_real: @good.garantia_real, good_activity_id: @good.good_activity_id, good_stage_id: @good.good_stage_id, grupo_solidario: @good.grupo_solidario, juicio_id: @good.juicio_id, nombre_grupo: @good.nombre_grupo, nombres: @good.nombres, observaciones: @good.observaciones, oficial_credito: @good.oficial_credito, parroquia: @good.parroquia, sector: @good.sector, socio_id: @good.socio_id, sucursal: @good.sucursal, tel_garante: @good.tel_garante, telefono: @good.telefono, tipo_credito: @good.tipo_credito, tipo_garantia: @good.tipo_garantia, valor_cartera_castigada: @good.valor_cartera_castigada } }
    end

    assert_redirected_to good_url(Good.last)
  end

  test "should show good" do
    get good_url(@good)
    assert_response :success
  end

  test "should get edit" do
    get edit_good_url(@good)
    assert_response :success
  end

  test "should update good" do
    patch good_url(@good), params: { good: { bienes: @good.bienes, canton: @good.canton, cartera_heredada: @good.cartera_heredada, cedula: @good.cedula, celular: @good.celular, codigo_juicio: @good.codigo_juicio, credit_id: @good.credit_id, dir_garante: @good.dir_garante, direccion: @good.direccion, estado: @good.estado, fcalificacion_juicio: @good.fcalificacion_juicio, fecha_concesion: @good.fecha_concesion, fecha_vencimiento: @good.fecha_vencimiento, fentrega_juicios: @good.fentrega_juicios, garantia_fiduciaria: @good.garantia_fiduciaria, garantia_real: @good.garantia_real, good_activity_id: @good.good_activity_id, good_stage_id: @good.good_stage_id, grupo_solidario: @good.grupo_solidario, juicio_id: @good.juicio_id, nombre_grupo: @good.nombre_grupo, nombres: @good.nombres, observaciones: @good.observaciones, oficial_credito: @good.oficial_credito, parroquia: @good.parroquia, sector: @good.sector, socio_id: @good.socio_id, sucursal: @good.sucursal, tel_garante: @good.tel_garante, telefono: @good.telefono, tipo_credito: @good.tipo_credito, tipo_garantia: @good.tipo_garantia, valor_cartera_castigada: @good.valor_cartera_castigada } }
    assert_redirected_to good_url(@good)
  end

  test "should destroy good" do
    assert_difference('Good.count', -1) do
      delete good_url(@good)
    end

    assert_redirected_to goods_url
  end
end
