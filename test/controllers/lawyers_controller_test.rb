require 'test_helper'

class LawyersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @lawyer = lawyers(:one)
  end

  test "should get index" do
    get lawyers_url
    assert_response :success
  end

  test "should get new" do
    get new_lawyer_url
    assert_response :success
  end

  test "should create lawyer" do
    assert_difference('Lawyer.count') do
      post lawyers_url, params: { lawyer: { lastname: @lawyer.lastname, name: @lawyer.name, phone: @lawyer.phone } }
    end

    assert_redirected_to lawyer_url(Lawyer.last)
  end

  test "should show lawyer" do
    get lawyer_url(@lawyer)
    assert_response :success
  end

  test "should get edit" do
    get edit_lawyer_url(@lawyer)
    assert_response :success
  end

  test "should update lawyer" do
    patch lawyer_url(@lawyer), params: { lawyer: { lastname: @lawyer.lastname, name: @lawyer.name, phone: @lawyer.phone } }
    assert_redirected_to lawyer_url(@lawyer)
  end

  test "should destroy lawyer" do
    assert_difference('Lawyer.count', -1) do
      delete lawyer_url(@lawyer)
    end

    assert_redirected_to lawyers_url
  end
end
