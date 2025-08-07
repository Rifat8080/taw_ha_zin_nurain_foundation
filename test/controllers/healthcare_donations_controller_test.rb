require "test_helper"

class HealthcareDonationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get healthcare_donations_index_url
    assert_response :success
  end

  test "should get show" do
    get healthcare_donations_show_url
    assert_response :success
  end

  test "should get new" do
    get healthcare_donations_new_url
    assert_response :success
  end

  test "should get create" do
    get healthcare_donations_create_url
    assert_response :success
  end
end
