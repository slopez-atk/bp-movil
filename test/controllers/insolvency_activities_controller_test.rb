require 'test_helper'

class InsolvencyActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @insolvency_activity = insolvency_activities(:one)
  end

  test "should get index" do
    get insolvency_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_insolvency_activity_url
    assert_response :success
  end

  test "should create insolvency_activity" do
    assert_difference('InsolvencyActivity.count') do
      post insolvency_activities_url, params: { insolvency_activity: { insolvency_stage_id: @insolvency_activity.insolvency_stage_id, name: @insolvency_activity.name } }
    end

    assert_redirected_to insolvency_activity_url(InsolvencyActivity.last)
  end

  test "should show insolvency_activity" do
    get insolvency_activity_url(@insolvency_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_insolvency_activity_url(@insolvency_activity)
    assert_response :success
  end

  test "should update insolvency_activity" do
    patch insolvency_activity_url(@insolvency_activity), params: { insolvency_activity: { insolvency_stage_id: @insolvency_activity.insolvency_stage_id, name: @insolvency_activity.name } }
    assert_redirected_to insolvency_activity_url(@insolvency_activity)
  end

  test "should destroy insolvency_activity" do
    assert_difference('InsolvencyActivity.count', -1) do
      delete insolvency_activity_url(@insolvency_activity)
    end

    assert_redirected_to insolvency_activities_url
  end
end
