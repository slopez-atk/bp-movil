require 'test_helper'

class PermissionHistoriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @permission_history = permission_histories(:one)
  end

  test "should get index" do
    get permission_histories_url
    assert_response :success
  end

  test "should get new" do
    get new_permission_history_url
    assert_response :success
  end

  test "should create permission_history" do
    assert_difference('PermissionHistory.count') do
      post permission_histories_url, params: { permission_history: { descripcion: @permission_history.descripcion, fecha_eliminacion: @permission_history.fecha_eliminacion, fecha_permiso: @permission_history.fecha_permiso, horas: @permission_history.horas, worker_id: @permission_history.worker_id } }
    end

    assert_redirected_to permission_history_url(PermissionHistory.last)
  end

  test "should show permission_history" do
    get permission_history_url(@permission_history)
    assert_response :success
  end

  test "should get edit" do
    get edit_permission_history_url(@permission_history)
    assert_response :success
  end

  test "should update permission_history" do
    patch permission_history_url(@permission_history), params: { permission_history: { descripcion: @permission_history.descripcion, fecha_eliminacion: @permission_history.fecha_eliminacion, fecha_permiso: @permission_history.fecha_permiso, horas: @permission_history.horas, worker_id: @permission_history.worker_id } }
    assert_redirected_to permission_history_url(@permission_history)
  end

  test "should destroy permission_history" do
    assert_difference('PermissionHistory.count', -1) do
      delete permission_history_url(@permission_history)
    end

    assert_redirected_to permission_histories_url
  end
end
