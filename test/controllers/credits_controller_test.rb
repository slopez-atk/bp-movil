require 'test_helper'

class CreditsControllerTest < ActionDispatch::IntegrationTest
  test "should get creditos_por_vencer" do
    get credits_creditos_por_vencer_url
    assert_response :success
  end

  test "should get creditos_vencidos" do
    get credits_creditos_vencidos_url
    assert_response :success
  end

  test "should get cosechas" do
    get credits_cosechas_url
    assert_response :success
  end

  test "should get matrices" do
    get credits_matrices_url
    assert_response :success
  end

  test "should get clientes_vip" do
    get credits_clientes_vip_url
    assert_response :success
  end

end
