require "test_helper"

class EventUsersControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get event_users_index_url
    assert_response :success
  end

  test "should get create" do
    get event_users_create_url
    assert_response :success
  end

  test "should get destroy" do
    get event_users_destroy_url
    assert_response :success
  end
end
