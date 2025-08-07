require "test_helper"

class HealthcareRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get healthcare_requests_index_url
    assert_response :success
  end

  test "should get show" do
    get healthcare_requests_show_url
    assert_response :success
  end

  test "should get new" do
    get healthcare_requests_new_url
    assert_response :success
  end

  test "should get create" do
    get healthcare_requests_create_url
    assert_response :success
  end

  test "should get edit" do
    get healthcare_requests_edit_url
    assert_response :success
  end

  test "should get update" do
    get healthcare_requests_update_url
    assert_response :success
  end

  test "should get destroy" do
    get healthcare_requests_destroy_url
    assert_response :success
  end
end
