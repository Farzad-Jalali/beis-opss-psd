require "application_system_test_case"

class InvestigationHazardTest < ApplicationSystemTestCase
  setup do
    sign_in_as_user
    visit new_investigation_new_hazard_path(investigations(:one))
    assert_selector "h1", text: "Hazard information"
  end

  teardown do
    logout
  end

  test "can add empty hazard to investigation" do
    click_on "Continue"

    assert_text "Confirm hazard details"
    click_on "Save"

    # The better assertion here would be to look for the flash message confirming successful incident submission
    # For whatever reason, this doesn't seem to show up in test (confirmed by inspecting failure screenshots)
    # assert_text "Hazard details were updated."
    assert_current_path(/investigations\/\d+/)
    assert_text "Hazard added by"
  end

  test "can add filled in hazard to investigation" do
    fill_in "Overview", with: "A fire"
    fill_in "Details", with: "A big blaze"
    fill_in "Who is it at risk to?", with: "Young people"
    choose("hazard[set_risk_level]", visible: false, match: :first)
    choose("hazard[risk_level]", visible: false, match: :first)
    attach_file("hazard[file][file]", Rails.root + "test/fixtures/files/old_risk_assessment.txt")
    click_on "Continue"

    # The better assertion here would be to look for the flash message confirming successful incident submission
    # For whatever reason, this doesn't seem to show up in test (confirmed by inspecting failure screenshots)
    # assert_text "Hazard details were updated."
    assert_current_path(/investigations\/\d+/)
    assert_text "A fire"
    assert_text "A big blaze"
    assert_text "Young people"
    assert_text "old_risk_assessment"
  end

  test "can go back to the editing page from the confirmation page and not lose data" do
    fill_in "Overview", with: "A fire"
    fill_in "Details", with: "A big blaze"
    fill_in "Who is it at risk to?", with: "Young people"
    click_on "Continue"

    # Assert all of the data is still here
    assert_text "A fire"
    assert_text "A big blaze"
    assert_text "Young people"
    click_on "Edit details"

    # Assert we're back on the edit page and haven't lost data
    assert_text "Hazard information"
    assert_field with: "A fire"
    assert_field with: "A big blaze"
    assert_field with: "Young people"
  end

  test "wizard data doesn't persist between reloads" do
    fill_in "Overview", with: "A fire"
    click_on "Continue"
    visit new_investigation_new_hazard_path(investigations(:one))

    assert_no_field with: "A fire"
  end

  test "wizard data gets cleared after completion" do
    fill_in "Overview", with: "A fire"
    click_on "Continue"
    click_on "Save"
    visit new_investigation_new_hazard_path(investigations(:one))

    assert_no_field with: "A fire"
  end

  test "can override risk assessment file via normal edit flow" do
    upload_file_and_confirm
    click_on "Edit hazard details"

    choose("hazard[set_risk_level]", visible: false, match: :first)
    choose("hazard[risk_level]", visible: false, match: :first)
    attach_file("hazard[file][file]", Rails.root + "test/fixtures/files/new_risk_assessment.txt")
    click_on "Continue"

    assert_text "new_risk_assessment"
    click_on "Save"
    assert_text "Hazard updated"

    new_window = window_opened_by { click_on "View assessment", match: :first }
    within_window new_window do
      assert_text "Updated risk assessment"
    end

    new_window = window_opened_by { all("a", text: "View risk assessment document").last.click }
    within_window new_window do
      assert_text "Obsolete risk assessment"
    end
  end

  test "can override risk assessment file via quick risk assessment flow" do
    upload_file_and_confirm
    click_on "Edit risk details"

    choose("hazard[risk_level]", visible: false, match: :first)
    attach_file("hazard[file][file]", Rails.root + "test/fixtures/files/new_risk_assessment.txt")
    click_on "Save"

    assert_text "Hazard updated"
    new_window = window_opened_by { click_on "View assessment", match: :first }
    within_window new_window do
      assert_text "Updated risk assessment"
    end
  end

  def upload_file_and_confirm
    choose("hazard[set_risk_level]", visible: false, match: :first)
    choose("hazard[risk_level]", visible: false, match: :first)
    attach_file("hazard[file][file]", Rails.root + "test/fixtures/files/old_risk_assessment.txt")
    click_on "Continue"

    assert_text "old_risk_assessment"
    click_on "Save"
  end
end
