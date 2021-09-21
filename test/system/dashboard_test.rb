require 'application_system_test_case'

class DashboardTest < ApplicationSystemTestCase
  test 'visiting the dashboard without session' do
    visit dashboard_url
    assert_selector 'h2', text: 'Log in'
  end

  test 'visiting the dashboard with creating a session' do
    visit dashboard_url
    fill_in 'Email', with: users(:alice).email
    fill_in 'Password', with: 'test'
    click_on 'Log in'

    visit dashboard_url
    assert_selector 'h1', text: 'Dashboard'
  end
end
