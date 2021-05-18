require "application_system_test_case"

class AccountsTest < ApplicationSystemTestCase
  setup do
    @domain = domains(:examplecom)

    visit domain_accounts_url(@domain)
    fill_in "Email", with: users(:alice).email
    fill_in "Password", with: 'test'
    click_on "Log in"
  end

  test "visiting the index" do
    visit domain_accounts_url(@domain)
    assert_selector "h1", text: "Accounts"
  end

  test "creating a account" do
    visit domain_accounts_url(@domain)
    click_on "New account"

    fill_in "Email", with: 'new-address@example.com'
    fill_in "Password", with: 'min10characters'
    click_on "Create account"

    assert_text "Account was successfully created"
    click_on "Back"
  end

  test "updating a account" do
    visit domain_accounts_url(@domain)
    click_on "Edit", match: :first

    uncheck "Enabled"
    click_on "Update account"

    assert_text "Account was successfully updated"
    click_on "Back"
  end

  test "destroying a account" do
    visit domain_accounts_url(@domain)
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Account was successfully destroyed"
  end
end
