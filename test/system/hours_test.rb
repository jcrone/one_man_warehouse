require "application_system_test_case"

class HoursTest < ApplicationSystemTestCase
  setup do
    @hour = hours(:one)
  end

  test "visiting the index" do
    visit hours_url
    assert_selector "h1", text: "Hours"
  end

  test "should create hour" do
    visit hours_url
    click_on "New hour"

    fill_in "Employee", with: @hour.employee_id
    fill_in "End date", with: @hour.end_date
    fill_in "Hours", with: @hour.hours
    fill_in "Pay date", with: @hour.pay_date
    fill_in "Start date", with: @hour.start_date
    fill_in "Status", with: @hour.status
    click_on "Create Hour"

    assert_text "Hour was successfully created"
    click_on "Back"
  end

  test "should update Hour" do
    visit hour_url(@hour)
    click_on "Edit this hour", match: :first

    fill_in "Employee", with: @hour.employee_id
    fill_in "End date", with: @hour.end_date
    fill_in "Hours", with: @hour.hours
    fill_in "Pay date", with: @hour.pay_date
    fill_in "Start date", with: @hour.start_date
    fill_in "Status", with: @hour.status
    click_on "Update Hour"

    assert_text "Hour was successfully updated"
    click_on "Back"
  end

  test "should destroy Hour" do
    visit hour_url(@hour)
    click_on "Destroy this hour", match: :first

    assert_text "Hour was successfully destroyed"
  end
end
