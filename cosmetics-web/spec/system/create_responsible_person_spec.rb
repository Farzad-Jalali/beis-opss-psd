require 'rails_helper'

RSpec.describe "Create a responsible person", type: :system do
  before do
    sign_in
    stub_notify_mailer
  end

  after do
    sign_out
  end

  it "succeeds with valid individual account details" do
    responsible_person = build(:responsible_person)
    contact_person = build(:contact_person)

    create_new_responsible_person
    select_individual_account_type

    assert_text "UK responsible person details"

    fill_in "Name", with: responsible_person.name
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_text "Contact person"

    fill_in "Full name", with: contact_person.name
    fill_in "Email address", with: contact_person.email_address
    fill_in "Phone number", with: contact_person.phone_number
    click_on "Continue"

    assert_current_path(/responsible_persons\/\d+\/verify/)
  end

  it "succeeds with valid business account details" do
    responsible_person = build(:business_responsible_person)
    contact_person = build(:contact_person)

    create_new_responsible_person
    select_business_account_type

    assert_text "UK responsible person details"

    fill_in "Business name", with: responsible_person.name
    fill_in "Building and street", with: responsible_person.address_line_1
    fill_in "Town or city", with: responsible_person.city
    fill_in "County", with: responsible_person.county
    fill_in "Postcode", with: responsible_person.postal_code
    click_on "Continue"

    assert_text "Contact person"

    fill_in "Full name", with: contact_person.name
    fill_in "Email address", with: contact_person.email_address
    fill_in "Phone number", with: contact_person.phone_number
    click_on "Continue"

    assert_current_path(/responsible_persons\/\d+\/verify/)
  end

  it "requires an account type to be selected" do
    visit account_path(:select_type)

    assert_text "Is the UK responsible person a business or an individual?"
    click_on "Continue"

    assert_current_path account_path(:select_type)
    assert_text "Account type can not be blank"
  end

  it "redirects to confirmation page on email validation" do
    responsible_person = create(:business_responsible_person)
    email_verification_key = responsible_person.email_verification_keys.create

    visit confirmation_path(email_verification_key.key)

    assert_current_path(/contact_persons\/confirm\/[a-zA-Z0-9_\-]+/)
  end

private

  def create_new_responsible_person
    visit account_path(:overview)
    assert_text "UK responsible person"
    click_on "Continue"

    assert_text "Do you or your organisation have an account to submit cosmetic product notifications in the UK?"
    choose "option_create_new", visible: false
    click_on "Continue"
  end

  def select_business_account_type
    assert_text "Is the UK responsible person a business or an individual?"
    choose "responsible_person_account_type_business", visible: false
    click_on "Continue"
  end

  def select_individual_account_type
    assert_text "Is the UK responsible person a business or an individual?"
    choose "responsible_person_account_type_individual", visible: false
    click_on "Continue"
  end
end
