# frozen_string_literal: true

require 'test_helper'

class HealthApiControllerTest < ActionDispatch::IntegrationTest
  test 'should get health endpoint without authorization' do
    get health_url

    assert_response :success
  end
end
