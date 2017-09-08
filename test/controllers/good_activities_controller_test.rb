require 'test_helper'

class GoodActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @good_activity = good_activities(:one)
  end

  test "should get index" do
    get good_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_good_activity_url
    assert_response :success
  end

  test "should create good_activity" do
    assert_difference('GoodActivity.count') do
      post good_activities_url, params: { good_activity: { good_stage_id: @good_activity.good_stage_id, name: @good_activity.name } }
    end

    assert_redirected_to good_activity_url(GoodActivity.last)
  end

  test "should show good_activity" do
    get good_activity_url(@good_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_good_activity_url(@good_activity)
    assert_response :success
  end

  test "should update good_activity" do
    patch good_activity_url(@good_activity), params: { good_activity: { good_stage_id: @good_activity.good_stage_id, name: @good_activity.name } }
    assert_redirected_to good_activity_url(@good_activity)
  end

  test "should destroy good_activity" do
    assert_difference('GoodActivity.count', -1) do
      delete good_activity_url(@good_activity)
    end

    assert_redirected_to good_activities_url
  end
end
