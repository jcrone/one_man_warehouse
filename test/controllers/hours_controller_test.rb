require "test_helper"

class HoursControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hour = hours(:one)
  end

  test "should get index" do
    get hours_url
    assert_response :success
  end

  test "should get new" do
    get new_hour_url
    assert_response :success
  end

  test "should create hour" do
    assert_difference("Hour.count") do
      post hours_url, params: { hour: { employee_id: @hour.employee_id, end_date: @hour.end_date, hours: @hour.hours, pay_date: @hour.pay_date, start_date: @hour.start_date, status: @hour.status } }
    end

    assert_redirected_to hour_url(Hour.last)
  end

  test "should show hour" do
    get hour_url(@hour)
    assert_response :success
  end

  test "should get edit" do
    get edit_hour_url(@hour)
    assert_response :success
  end

  test "should update hour" do
    patch hour_url(@hour), params: { hour: { employee_id: @hour.employee_id, end_date: @hour.end_date, hours: @hour.hours, pay_date: @hour.pay_date, start_date: @hour.start_date, status: @hour.status } }
    assert_redirected_to hour_url(@hour)
  end

  test "should destroy hour" do
    assert_difference("Hour.count", -1) do
      delete hour_url(@hour)
    end

    assert_redirected_to hours_url
  end
end
