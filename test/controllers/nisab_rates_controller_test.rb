require "test_helper"

class NisabRatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get nisab_rates_index_url
    assert_response :success
  end

  test "should get show" do
    get nisab_rates_show_url
    assert_response :success
  end

  test "should get new" do
    get nisab_rates_new_url
    assert_response :success
  end

  test "should get create" do
    get nisab_rates_create_url
    assert_response :success
  end

  test "should get edit" do
    get nisab_rates_edit_url
    assert_response :success
  end

  test "should get update" do
    get nisab_rates_update_url
    assert_response :success
  end

  test "should get destroy" do
    get nisab_rates_destroy_url
    assert_response :success
  end
end
