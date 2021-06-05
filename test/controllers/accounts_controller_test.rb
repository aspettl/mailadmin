require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @domain = domains(:examplecom)
    @account = accounts(:postmaster)
    @destroyable_account = accounts(:disabled_alias)
    sign_in users(:alice)
  end

  test "should be logged in" do
    sign_out users(:alice)
    get domain_accounts_url(@domain)
    assert_redirected_to new_user_session_url
  end

  test "should get index" do
    get domain_accounts_url(@domain)
    assert_response :success
  end

  test "should get new" do
    get new_domain_account_url(@domain)
    assert_response :success
  end

  test "should create account" do
    assert_difference('Account.count') do
      post domain_accounts_url(@domain), params: { account: { email: 'new-address@example.com', enabled: true, password: 'min10characters' } }
    end

    assert_redirected_to domain_account_url(@domain, Account.last)
  end

  test "should show account" do
    get domain_account_url(@domain, @account)
    assert_response :success
  end

  test "should get edit" do
    get edit_domain_account_url(@domain, @account)
    assert_response :success
  end

  test "should update account" do
    patch domain_account_url(@domain, @account), params: { account: { enabled: false } }
    assert_redirected_to domain_account_url(@domain, @account)
  end

  test "should destroy account" do
    assert_difference('Account.count', -1) do
      delete domain_account_url(@domain, @destroyable_account)
    end

    assert_redirected_to domain_accounts_url(@domain)
  end

  test "should not destroy account that has known alias addresses" do
    assert_no_difference('Account.count') do
      delete domain_account_url(@domain, @account)
    end

    assert_redirected_to domain_account_url(@domain, @account)
  end

  test "should force-destroy account that has known alias addresses" do
    assert_difference('Account.count', -1) do
      delete domain_account_url(@domain, @account, force: "true")
    end

    assert_redirected_to domain_accounts_url(@domain)
  end
end
