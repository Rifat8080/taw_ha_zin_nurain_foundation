require "test_helper"

class ZakatCalculationsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get zakat_calculations_index_url
    assert_response :success
  end

  test "should get show" do
    get zakat_calculations_show_url
    assert_response :success
  end

  test "should get new" do
    get zakat_calculations_new_url
    assert_response :success
  end

  test "should get create" do
    get zakat_calculations_create_url
    assert_response :success
  end

  test "should get edit" do
    get zakat_calculations_edit_url
    assert_response :success
  end

  test "should get update" do
    get zakat_calculations_update_url
    assert_response :success
  end

  test "should get destroy" do
    get zakat_calculations_destroy_url
    assert_response :success
  end
end
