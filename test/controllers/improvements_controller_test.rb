require "test_helper"

class ImprovementsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get improvements_new_url
    assert_response :success
  end
end
