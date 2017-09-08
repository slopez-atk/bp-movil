require 'test_helper'

class InsolvencyStagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @insolvency_stage = insolvency_stages(:one)
  end

  test "should get index" do
    get insolvency_stages_url
    assert_response :success
  end

  test "should get new" do
    get new_insolvency_stage_url
    assert_response :success
  end

  test "should create insolvency_stage" do
    assert_difference('InsolvencyStage.count') do
      post insolvency_stages_url, params: { insolvency_stage: { days: @insolvency_stage.days, months: @insolvency_stage.months, name: @insolvency_stage.name } }
    end

    assert_redirected_to insolvency_stage_url(InsolvencyStage.last)
  end

  test "should show insolvency_stage" do
    get insolvency_stage_url(@insolvency_stage)
    assert_response :success
  end

  test "should get edit" do
    get edit_insolvency_stage_url(@insolvency_stage)
    assert_response :success
  end

  test "should update insolvency_stage" do
    patch insolvency_stage_url(@insolvency_stage), params: { insolvency_stage: { days: @insolvency_stage.days, months: @insolvency_stage.months, name: @insolvency_stage.name } }
    assert_redirected_to insolvency_stage_url(@insolvency_stage)
  end

  test "should destroy insolvency_stage" do
    assert_difference('InsolvencyStage.count', -1) do
      delete insolvency_stage_url(@insolvency_stage)
    end

    assert_redirected_to insolvency_stages_url
  end
end
