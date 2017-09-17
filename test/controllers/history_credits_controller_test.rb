require 'test_helper'

class HistoryCreditsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @history_credit = history_credits(:one)
  end

  test "should get index" do
    get history_credits_url
    assert_response :success
  end

  test "should get new" do
    get new_history_credit_url
    assert_response :success
  end

  test "should create history_credit" do
    assert_difference('HistoryCredit.count') do
      post history_credits_url, params: { history_credit: { abogado: @history_credit.abogado, agencia: @history_credit.agencia, asesor: @history_credit.asesor, cedula: @history_credit.cedula, credit_id: @history_credit.credit_id, estado: @history_credit.estado, semaforo: @history_credit.semaforo, socio_id: @history_credit.socio_id } }
    end

    assert_redirected_to history_credit_url(HistoryCredit.last)
  end

  test "should show history_credit" do
    get history_credit_url(@history_credit)
    assert_response :success
  end

  test "should get edit" do
    get edit_history_credit_url(@history_credit)
    assert_response :success
  end

  test "should update history_credit" do
    patch history_credit_url(@history_credit), params: { history_credit: { abogado: @history_credit.abogado, agencia: @history_credit.agencia, asesor: @history_credit.asesor, cedula: @history_credit.cedula, credit_id: @history_credit.credit_id, estado: @history_credit.estado, semaforo: @history_credit.semaforo, socio_id: @history_credit.socio_id } }
    assert_redirected_to history_credit_url(@history_credit)
  end

  test "should destroy history_credit" do
    assert_difference('HistoryCredit.count', -1) do
      delete history_credit_url(@history_credit)
    end

    assert_redirected_to history_credits_url
  end
end
