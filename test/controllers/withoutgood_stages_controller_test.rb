require 'test_helper'

class WithoutgoodStagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @withoutgood_stage = withoutgood_stages(:one)
  end

  test "should get index" do
    get withoutgood_stages_url
    assert_response :success
  end

  test "should get new" do
    get new_withoutgood_stage_url
    assert_response :success
  end

  test "should create withoutgood_stage" do
    assert_difference('WithoutgoodStage.count') do
      post withoutgood_stages_url, params: { withoutgood_stage: { days: @withoutgood_stage.days, months: @withoutgood_stage.months, name: @withoutgood_stage.name } }
    end

    assert_redirected_to withoutgood_stage_url(WithoutgoodStage.last)
  end

  test "should show withoutgood_stage" do
    get withoutgood_stage_url(@withoutgood_stage)
    assert_response :success
  end

  test "should get edit" do
    get edit_withoutgood_stage_url(@withoutgood_stage)
    assert_response :success
  end

  test "should update withoutgood_stage" do
    patch withoutgood_stage_url(@withoutgood_stage), params: { withoutgood_stage: { days: @withoutgood_stage.days, months: @withoutgood_stage.months, name: @withoutgood_stage.name } }
    assert_redirected_to withoutgood_stage_url(@withoutgood_stage)
  end

  test "should destroy withoutgood_stage" do
    assert_difference('WithoutgoodStage.count', -1) do
      delete withoutgood_stage_url(@withoutgood_stage)
    end

    assert_redirected_to withoutgood_stages_url
  end
end
