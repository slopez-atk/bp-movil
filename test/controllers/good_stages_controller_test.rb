require 'test_helper'

class GoodStagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @good_stage = good_stages(:one)
  end

  test "should get index" do
    get good_stages_url
    assert_response :success
  end

  test "should get new" do
    get new_good_stage_url
    assert_response :success
  end

  test "should create good_stage" do
    assert_difference('GoodStage.count') do
      post good_stages_url, params: { good_stage: { days: @good_stage.days, months: @good_stage.months, name: @good_stage.name } }
    end

    assert_redirected_to good_stage_url(GoodStage.last)
  end

  test "should show good_stage" do
    get good_stage_url(@good_stage)
    assert_response :success
  end

  test "should get edit" do
    get edit_good_stage_url(@good_stage)
    assert_response :success
  end

  test "should update good_stage" do
    patch good_stage_url(@good_stage), params: { good_stage: { days: @good_stage.days, months: @good_stage.months, name: @good_stage.name } }
    assert_redirected_to good_stage_url(@good_stage)
  end

  test "should destroy good_stage" do
    assert_difference('GoodStage.count', -1) do
      delete good_stage_url(@good_stage)
    end

    assert_redirected_to good_stages_url
  end
end
