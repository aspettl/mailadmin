require 'application_system_test_case'

class DomainsTest < ApplicationSystemTestCase
  setup do
    @domain = domains(:examplecom)
    @destroyable_domain = domains(:exampleorg)

    visit domains_url
    fill_in 'Email', with: users(:alice).email
    fill_in 'Password', with: 'test'
    click_on 'Log in'
  end

  test 'visiting the index' do
    visit domains_url
    assert_selector 'h1', text: 'Domains'
  end

  test 'creating a domain' do
    visit domains_url
    click_on 'New domain', match: :first

    fill_in 'Domain', with: 'new-domain.abc'
    check 'Enabled'
    click_on 'Create domain'

    assert_text 'Domain was successfully created'
    click_on 'Back'
  end

  test 'updating a domain' do
    visit domains_url
    click_on 'Edit', match: :first

    uncheck 'Enabled'
    click_on 'Update domain'

    assert_text 'Domain was successfully updated'
    click_on 'Back'
  end

  test 'destroying a domain' do
    visit domain_url(@destroyable_domain)
    page.accept_confirm do
      click_on 'Destroy', match: :first
    end

    assert_text 'Domain was successfully destroyed'
  end
end
