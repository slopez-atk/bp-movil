require 'test_helper'

class MainControllerTest < ActionDispatch::IntegrationTest
  test "should get Home" do
    get main_Home_url
    assert_response :success
  end

end
