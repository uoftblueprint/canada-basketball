require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "home page renders" do
    get root_url
    assert_response :success
    assert_select "h1", "Canada Basketball"
  end
end
