require 'test_helper'

class DomainsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @domain = domains(:examplecom)
    @destroyable_domain = domains(:exampleorg)
    sign_in users(:alice)
  end

  test 'should be logged in' do
    sign_out users(:alice)
    get domains_url
    assert_redirected_to new_user_session_url
  end

  test 'should get index' do
    get domains_url
    assert_response :success
  end

  test 'should get new' do
    get new_domain_url
    assert_response :success
  end

  test 'should create domain' do
    assert_difference('Domain.count') do
      post domains_url, params: { domain: { domain: 'new-domain.abc', enabled: true, user_id: users(:alice).id } }
    end

    assert_redirected_to domain_url(Domain.last)
  end

  test 'should show domain' do
    get domain_url(@domain)
    assert_response :success
  end

  test 'should get edit' do
    get edit_domain_url(@domain)
    assert_response :success
  end

  test 'should update domain' do
    patch domain_url(@domain), params: { domain: { enabled: false } }
    assert_redirected_to domain_url(@domain)
  end

  test 'should destroy domain' do
    assert_difference('Domain.count', -1) do
      delete domain_url(@destroyable_domain)
    end

    assert_redirected_to domains_url
  end

  test 'should not destroy domain that has accounts' do
    assert_no_difference('Domain.count') do
      delete domain_url(@domain)
    end

    assert_redirected_to domain_url(@domain)
  end

  test 'should force-destroy domain that has accounts' do
    assert_difference('Domain.count', -1) do
      delete domain_url(@domain, force: 'true')
    end

    assert_redirected_to domains_url
  end
end
