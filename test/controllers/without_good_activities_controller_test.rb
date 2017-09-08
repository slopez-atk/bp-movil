require 'test_helper'

class WithoutGoodActivitiesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @without_good_activity = without_good_activities(:one)
  end

  test "should get index" do
    get without_good_activities_url
    assert_response :success
  end

  test "should get new" do
    get new_without_good_activity_url
    assert_response :success
  end

  test "should create without_good_activity" do
    assert_difference('WithoutGoodActivity.count') do
      post without_good_activities_url, params: { without_good_activity: { name: @without_good_activity.name, withoutgood_stage_id: @without_good_activity.withoutgood_stage_id } }
    end

    assert_redirected_to without_good_activity_url(WithoutGoodActivity.last)
  end

  test "should show without_good_activity" do
    get without_good_activity_url(@without_good_activity)
    assert_response :success
  end

  test "should get edit" do
    get edit_without_good_activity_url(@without_good_activity)
    assert_response :success
  end

  test "should update without_good_activity" do
    patch without_good_activity_url(@without_good_activity), params: { without_good_activity: { name: @without_good_activity.name, withoutgood_stage_id: @without_good_activity.withoutgood_stage_id } }
    assert_redirected_to without_good_activity_url(@without_good_activity)
  end

  test "should destroy without_good_activity" do
    assert_difference('WithoutGoodActivity.count', -1) do
      delete without_good_activity_url(@without_good_activity)
    end

    assert_redirected_to without_good_activities_url
  end
end
