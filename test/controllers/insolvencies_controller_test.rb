require 'test_helper'

class InsolvenciesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @insolvency = insolvencies(:one)
  end

  test "should get index" do
    get insolvencies_url
    assert_response :success
  end

  test "should get new" do
    get new_insolvency_url
    assert_response :success
  end

  test "should create insolvency" do
    assert_difference('Insolvency.count') do
      post insolvencies_url, params: { insolvency: { bienes: @insolvency.bienes, canton: @insolvency.canton, cartera_heredada: @insolvency.cartera_heredada, cedula: @insolvency.cedula, celular: @insolvency.celular, codigo_juicio: @insolvency.codigo_juicio, credit_id: @insolvency.credit_id, dir_garante: @insolvency.dir_garante, direccion: @insolvency.direccion, estado: @insolvency.estado, fcalificacion_juicio: @insolvency.fcalificacion_juicio, fecha_concesion: @insolvency.fecha_concesion, fecha_vencimiento: @insolvency.fecha_vencimiento, fentrega_juicios: @insolvency.fentrega_juicios, garantia_fiduciaria: @insolvency.garantia_fiduciaria, garantia_real: @insolvency.garantia_real, grupo_solidario: @insolvency.grupo_solidario, insolvency_activity_id: @insolvency.insolvency_activity_id, insolvency_stage_id: @insolvency.insolvency_stage_id, juicio_id: @insolvency.juicio_id, nombre_grupo: @insolvency.nombre_grupo, nombres: @insolvency.nombres, observaciones: @insolvency.observaciones, oficial_credito: @insolvency.oficial_credito, parroquia: @insolvency.parroquia, sector: @insolvency.sector, socio_id: @insolvency.socio_id, sucursal: @insolvency.sucursal, tel_garante: @insolvency.tel_garante, telefono: @insolvency.telefono, tipo_credito: @insolvency.tipo_credito, tipo_garantia: @insolvency.tipo_garantia, valor_cartera_castigada: @insolvency.valor_cartera_castigada } }
    end

    assert_redirected_to insolvency_url(Insolvency.last)
  end

  test "should show insolvency" do
    get insolvency_url(@insolvency)
    assert_response :success
  end

  test "should get edit" do
    get edit_insolvency_url(@insolvency)
    assert_response :success
  end

  test "should update insolvency" do
    patch insolvency_url(@insolvency), params: { insolvency: { bienes: @insolvency.bienes, canton: @insolvency.canton, cartera_heredada: @insolvency.cartera_heredada, cedula: @insolvency.cedula, celular: @insolvency.celular, codigo_juicio: @insolvency.codigo_juicio, credit_id: @insolvency.credit_id, dir_garante: @insolvency.dir_garante, direccion: @insolvency.direccion, estado: @insolvency.estado, fcalificacion_juicio: @insolvency.fcalificacion_juicio, fecha_concesion: @insolvency.fecha_concesion, fecha_vencimiento: @insolvency.fecha_vencimiento, fentrega_juicios: @insolvency.fentrega_juicios, garantia_fiduciaria: @insolvency.garantia_fiduciaria, garantia_real: @insolvency.garantia_real, grupo_solidario: @insolvency.grupo_solidario, insolvency_activity_id: @insolvency.insolvency_activity_id, insolvency_stage_id: @insolvency.insolvency_stage_id, juicio_id: @insolvency.juicio_id, nombre_grupo: @insolvency.nombre_grupo, nombres: @insolvency.nombres, observaciones: @insolvency.observaciones, oficial_credito: @insolvency.oficial_credito, parroquia: @insolvency.parroquia, sector: @insolvency.sector, socio_id: @insolvency.socio_id, sucursal: @insolvency.sucursal, tel_garante: @insolvency.tel_garante, telefono: @insolvency.telefono, tipo_credito: @insolvency.tipo_credito, tipo_garantia: @insolvency.tipo_garantia, valor_cartera_castigada: @insolvency.valor_cartera_castigada } }
    assert_redirected_to insolvency_url(@insolvency)
  end

  test "should destroy insolvency" do
    assert_difference('Insolvency.count', -1) do
      delete insolvency_url(@insolvency)
    end

    assert_redirected_to insolvencies_url
  end
end
