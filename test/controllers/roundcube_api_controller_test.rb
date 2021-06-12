require "test_helper"

class RoundcubeApiControllerTest < ActionDispatch::IntegrationTest
  NEW_PASSWORD = 'brSfAjXVAp'

  setup do
    @account = accounts(:postmaster)
  end

  test "should not update password without params" do
    post roundcube_password_url

    assert_response :unauthorized
  end

  test "should not update password with wrong email" do
    post roundcube_password_url, params: { email: 'non-existent@example.com', current_password: 'test', new_password: NEW_PASSWORD }

    assert_response :unauthorized
  end

  test "should not update password without current password" do
    post roundcube_password_url, params: { email: @account.email, new_password: NEW_PASSWORD }

    assert_response :unauthorized
  end

  test "should not update password with wrong current password" do
    post roundcube_password_url, params: { email: @account.email, current_password: 'wrong', new_password: NEW_PASSWORD }

    assert_response :unauthorized
    @account.reload
    assert_not @account.matches_crypted_password?(NEW_PASSWORD)
  end

  test "should update password" do
    post roundcube_password_url, params: { email: @account.email, current_password: 'test', new_password: NEW_PASSWORD }

    assert_response :success
    @account.reload
    assert @account.matches_crypted_password?(NEW_PASSWORD)
  end

  test "should not update password on validation error (too short)" do
    old_crypt = @account.crypt

    post roundcube_password_url, params: { email: @account.email, current_password: 'test', new_password: 'tooshort' }

    assert_response :bad_request
    @account.reload
    assert_equal old_crypt, @account.crypt
  end

  test "should not update password on validation error (pwned)" do
    old_crypt = @account.crypt

    post roundcube_password_url, params: { email: @account.email, current_password: 'test', new_password: 'newpassword' }

    assert_response :bad_request
    @account.reload
    assert_equal old_crypt, @account.crypt
  end
end
