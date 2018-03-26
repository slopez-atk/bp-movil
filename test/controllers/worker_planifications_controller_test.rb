require 'test_helper'

class WorkerPlanificationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @worker_planification = worker_planifications(:one)
  end

  test "should get index" do
    get worker_planifications_url
    assert_response :success
  end

  test "should get new" do
    get new_worker_planification_url
    assert_response :success
  end

  test "should create worker_planification" do
    assert_difference('WorkerPlanification.count') do
      post worker_planifications_url, params: { worker_planification: { end_date: @worker_planification.end_date, horas_estimadas: @worker_planification.horas_estimadas, start_date: @worker_planification.start_date, worker_id: @worker_planification.worker_id } }
    end

    assert_redirected_to worker_planification_url(WorkerPlanification.last)
  end

  test "should show worker_planification" do
    get worker_planification_url(@worker_planification)
    assert_response :success
  end

  test "should get edit" do
    get edit_worker_planification_url(@worker_planification)
    assert_response :success
  end

  test "should update worker_planification" do
    patch worker_planification_url(@worker_planification), params: { worker_planification: { end_date: @worker_planification.end_date, horas_estimadas: @worker_planification.horas_estimadas, start_date: @worker_planification.start_date, worker_id: @worker_planification.worker_id } }
    assert_redirected_to worker_planification_url(@worker_planification)
  end

  test "should destroy worker_planification" do
    assert_difference('WorkerPlanification.count', -1) do
      delete worker_planification_url(@worker_planification)
    end

    assert_redirected_to worker_planifications_url
  end
end
