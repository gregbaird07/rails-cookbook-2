require "test_helper"

class FavoritesControllerTest < ActionDispatch::IntegrationTest
  test "should get toggle" do
    get favorites_toggle_url
    assert_response :success
  end
end
