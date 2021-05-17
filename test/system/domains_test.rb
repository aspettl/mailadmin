require "application_system_test_case"

class DomainsTest < ApplicationSystemTestCase
  setup do
    @domain = domains(:one)
  end

  test "visiting the index" do
    visit domains_url
    assert_selector "h1", text: "Domains"
  end

  test "creating a Domain" do
    visit domains_url
    click_on "New Domain"

    fill_in "Domain", with: @domain.domain
    check "Enabled" if @domain.enabled
    fill_in "User", with: @domain.user_id
    click_on "Create Domain"

    assert_text "Domain was successfully created"
    click_on "Back"
  end

  test "updating a Domain" do
    visit domains_url
    click_on "Edit", match: :first

    fill_in "Domain", with: @domain.domain
    check "Enabled" if @domain.enabled
    fill_in "User", with: @domain.user_id
    click_on "Update Domain"

    assert_text "Domain was successfully updated"
    click_on "Back"
  end

  test "destroying a Domain" do
    visit domains_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Domain was successfully destroyed"
  end
end
