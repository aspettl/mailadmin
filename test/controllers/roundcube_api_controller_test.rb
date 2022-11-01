# frozen_string_literal: true

require 'test_helper'

class RoundcubeApiControllerTest < ActionDispatch::IntegrationTest
  NEW_PASSWORD = 'brSfAjXVAp'

  setup do
    @account = accounts(:postmaster)
  end

  test 'should not update password without params' do
    post roundcube_password_url

    assert_response :unauthorized
  end

  test 'should not update password with wrong email' do
    post roundcube_password_url, params: { user: 'non-existent@example.com', curpass: 'test', newpass: NEW_PASSWORD }

    assert_response :unauthorized
  end

  test 'should not update password without current password' do
    post roundcube_password_url, params: { user: @account.email, newpass: NEW_PASSWORD }

    assert_response :unauthorized
  end

  test 'should not update password with wrong current password' do
    post roundcube_password_url, params: { user: @account.email, curpass: 'wrong', newpass: NEW_PASSWORD }

    assert_response :unauthorized
    @account.reload

    assert_not @account.matches_crypted_password?(NEW_PASSWORD)
  end

  test 'should update password' do
    post roundcube_password_url, params: { user: @account.email, curpass: 'test', newpass: NEW_PASSWORD }

    assert_response :success
    assert_equal 'OK', response.body
    @account.reload

    assert @account.matches_crypted_password?(NEW_PASSWORD)
  end

  test 'should not update password when no new password given' do
    old_crypt = @account.crypt

    post roundcube_password_url, params: { user: @account.email, curpass: 'test', newpass: '' }

    assert_response :bad_request
    @account.reload

    assert_equal old_crypt, @account.crypt
  end

  test 'should not update password on validation error (too short)' do
    old_crypt = @account.crypt

    post roundcube_password_url, params: { user: @account.email, curpass: 'test', newpass: 'sfhj3we4i' }

    assert_response :success
    assert_equal 'Validation failed: Password is too short (minimum is 10 characters)', response.body
    @account.reload

    assert_equal old_crypt, @account.crypt
  end

  test 'should not update password on validation error (pwned)' do
    old_crypt = @account.crypt

    post roundcube_password_url, params: { user: @account.email, curpass: 'test', newpass: 'newpassword' }

    assert_response :success
    assert_equal 'Validation failed: Password has previously appeared in a data breach and should not be used',
                 response.body
    @account.reload

    assert_equal old_crypt, @account.crypt
  end
end
