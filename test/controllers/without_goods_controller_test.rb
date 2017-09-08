require 'test_helper'

class WithoutGoodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @without_good = without_goods(:one)
  end

  test "should get index" do
    get without_goods_url
    assert_response :success
  end

  test "should get new" do
    get new_without_good_url
    assert_response :success
  end

  test "should create without_good" do
    assert_difference('WithoutGood.count') do
      post without_goods_url, params: { without_good: { bienes: @without_good.bienes, canton: @without_good.canton, cartera_heredada: @without_good.cartera_heredada, cedula: @without_good.cedula, celular: @without_good.celular, codigo_juicio: @without_good.codigo_juicio, credit_id: @without_good.credit_id, dir_garante: @without_good.dir_garante, direccion: @without_good.direccion, estado: @without_good.estado, fcalificacion_juicio: @without_good.fcalificacion_juicio, fecha_concesion: @without_good.fecha_concesion, fecha_vencimiento: @without_good.fecha_vencimiento, fentrega_juicios: @without_good.fentrega_juicios, garantia_fiduciaria: @without_good.garantia_fiduciaria, garantia_real: @without_good.garantia_real, grupo_solidario: @without_good.grupo_solidario, juicio_id: @without_good.juicio_id, nombre_grupo: @without_good.nombre_grupo, nombres: @without_good.nombres, observaciones: @without_good.observaciones, oficial_credito: @without_good.oficial_credito, parroquia: @without_good.parroquia, sector: @without_good.sector, socio_id: @without_good.socio_id, sucursal: @without_good.sucursal, tel_garante: @without_good.tel_garante, telefono: @without_good.telefono, tipo_credito: @without_good.tipo_credito, tipo_garantia: @without_good.tipo_garantia, valor_cartera_castigada: @without_good.valor_cartera_castigada, without_good_activity_id: @without_good.without_good_activity_id, withoutgood_stage_id: @without_good.withoutgood_stage_id } }
    end

    assert_redirected_to without_good_url(WithoutGood.last)
  end

  test "should show without_good" do
    get without_good_url(@without_good)
    assert_response :success
  end

  test "should get edit" do
    get edit_without_good_url(@without_good)
    assert_response :success
  end

  test "should update without_good" do
    patch without_good_url(@without_good), params: { without_good: { bienes: @without_good.bienes, canton: @without_good.canton, cartera_heredada: @without_good.cartera_heredada, cedula: @without_good.cedula, celular: @without_good.celular, codigo_juicio: @without_good.codigo_juicio, credit_id: @without_good.credit_id, dir_garante: @without_good.dir_garante, direccion: @without_good.direccion, estado: @without_good.estado, fcalificacion_juicio: @without_good.fcalificacion_juicio, fecha_concesion: @without_good.fecha_concesion, fecha_vencimiento: @without_good.fecha_vencimiento, fentrega_juicios: @without_good.fentrega_juicios, garantia_fiduciaria: @without_good.garantia_fiduciaria, garantia_real: @without_good.garantia_real, grupo_solidario: @without_good.grupo_solidario, juicio_id: @without_good.juicio_id, nombre_grupo: @without_good.nombre_grupo, nombres: @without_good.nombres, observaciones: @without_good.observaciones, oficial_credito: @without_good.oficial_credito, parroquia: @without_good.parroquia, sector: @without_good.sector, socio_id: @without_good.socio_id, sucursal: @without_good.sucursal, tel_garante: @without_good.tel_garante, telefono: @without_good.telefono, tipo_credito: @without_good.tipo_credito, tipo_garantia: @without_good.tipo_garantia, valor_cartera_castigada: @without_good.valor_cartera_castigada, without_good_activity_id: @without_good.without_good_activity_id, withoutgood_stage_id: @without_good.withoutgood_stage_id } }
    assert_redirected_to without_good_url(@without_good)
  end

  test "should destroy without_good" do
    assert_difference('WithoutGood.count', -1) do
      delete without_good_url(@without_good)
    end

    assert_redirected_to without_goods_url
  end
end
