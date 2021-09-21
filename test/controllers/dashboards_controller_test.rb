# frozen_string_literal: true

require 'test_helper'

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  test 'should not get dashboard when not logged in' do
    get dashboard_url
    assert_redirected_to new_user_session_url
  end

  test 'should get dashboard when logged in' do
    sign_in users(:alice)
    get dashboard_url
    assert_response :success
  end
end
