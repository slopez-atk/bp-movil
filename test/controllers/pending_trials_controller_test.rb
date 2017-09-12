require 'test_helper'

class PendingTrialsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @pending_trial = pending_trials(:one)
  end

  test "should get index" do
    get pending_trials_url
    assert_response :success
  end

  test "should get new" do
    get new_pending_trial_url
    assert_response :success
  end

  test "should create pending_trial" do
    assert_difference('PendingTrial.count') do
      post pending_trials_url, params: { pending_trial: { bienes: @pending_trial.bienes, canton: @pending_trial.canton, cartera_heredada: @pending_trial.cartera_heredada, cedula: @pending_trial.cedula, celular: @pending_trial.celular, credit_id: @pending_trial.credit_id, dir_garante: @pending_trial.dir_garante, direccion: @pending_trial.direccion, fecha_concesion: @pending_trial.fecha_concesion, fecha_vencimiento: @pending_trial.fecha_vencimiento, garantia_fiduciaria: @pending_trial.garantia_fiduciaria, garantia_real: @pending_trial.garantia_real, grupo_solidario: @pending_trial.grupo_solidario, nombre_grupo: @pending_trial.nombre_grupo, nombres: @pending_trial.nombres, oficial_credito: @pending_trial.oficial_credito, parroquia: @pending_trial.parroquia, sector: @pending_trial.sector, socio_id: @pending_trial.socio_id, sucursal: @pending_trial.sucursal, tel_garante: @pending_trial.tel_garante, telefono: @pending_trial.telefono, tipo_credito: @pending_trial.tipo_credito, tipo_garantia: @pending_trial.tipo_garantia, valor_cartera_castigada: @pending_trial.valor_cartera_castigada } }
    end

    assert_redirected_to pending_trial_url(PendingTrial.last)
  end

  test "should show pending_trial" do
    get pending_trial_url(@pending_trial)
    assert_response :success
  end

  test "should get edit" do
    get edit_pending_trial_url(@pending_trial)
    assert_response :success
  end

  test "should update pending_trial" do
    patch pending_trial_url(@pending_trial), params: { pending_trial: { bienes: @pending_trial.bienes, canton: @pending_trial.canton, cartera_heredada: @pending_trial.cartera_heredada, cedula: @pending_trial.cedula, celular: @pending_trial.celular, credit_id: @pending_trial.credit_id, dir_garante: @pending_trial.dir_garante, direccion: @pending_trial.direccion, fecha_concesion: @pending_trial.fecha_concesion, fecha_vencimiento: @pending_trial.fecha_vencimiento, garantia_fiduciaria: @pending_trial.garantia_fiduciaria, garantia_real: @pending_trial.garantia_real, grupo_solidario: @pending_trial.grupo_solidario, nombre_grupo: @pending_trial.nombre_grupo, nombres: @pending_trial.nombres, oficial_credito: @pending_trial.oficial_credito, parroquia: @pending_trial.parroquia, sector: @pending_trial.sector, socio_id: @pending_trial.socio_id, sucursal: @pending_trial.sucursal, tel_garante: @pending_trial.tel_garante, telefono: @pending_trial.telefono, tipo_credito: @pending_trial.tipo_credito, tipo_garantia: @pending_trial.tipo_garantia, valor_cartera_castigada: @pending_trial.valor_cartera_castigada } }
    assert_redirected_to pending_trial_url(@pending_trial)
  end

  test "should destroy pending_trial" do
    assert_difference('PendingTrial.count', -1) do
      delete pending_trial_url(@pending_trial)
    end

    assert_redirected_to pending_trials_url
  end
end
