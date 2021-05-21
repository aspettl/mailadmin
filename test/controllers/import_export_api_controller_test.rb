require "test_helper"

class ImportExportApiControllerTest < ActionDispatch::IntegrationTest
  test "should not backup when API auth not configured" do
    set_required_token('')

    get backup_url, headers: { Authorization: 'Bearer invalid-token' }

    assert_response :internal_server_error
  end

  test "should not backup with incorrect bearer token" do
    set_required_token('something')

    get backup_url, headers: { Authorization: 'Bearer something-else' }

    assert_response :unauthorized
  end

  test "should backup with correct bearer token" do
    set_required_token('valid-token')

    get backup_url, headers: { Authorization: 'Bearer valid-token' }

    assert_response :success
    assert_equal Domain.all.to_set, assigns(:domains).to_set
    assert_equal Account.all.to_set, assigns(:accounts).to_set
  end

  test "should not export when API auth not configured" do
    set_required_token('')

    get export_url, headers: { Authorization: 'Bearer invalid-token' }

    assert_response :internal_server_error
  end

  test "should not export with incorrect bearer token" do
    set_required_token('something')

    get export_url, headers: { Authorization: 'Bearer something-else' }

    assert_response :unauthorized
  end

  test "should export with correct bearer token" do
    set_required_token('valid-token')

    get export_url, headers: { Authorization: 'Bearer valid-token' }

    assert_response :success
    assert_equal [domains(:examplecom), domains(:exampleorg)].to_set, assigns(:local_domains).to_set
    assert_equal [domains(:examplenet)].to_set, assigns(:alias_domains).to_set
    assert_equal [accounts(:postmaster), accounts(:mailbox)].to_set, assigns(:local_mailboxes).to_set
    assert_equal [accounts(:alias)].to_set, assigns(:alias_addresses).to_set
    assert_equal [accounts(:drop)].to_set, assigns(:blackhole_addresses).to_set
  end

  private
    def set_required_token(required)
      GlobalConfiguration::API.token = required
    end
end
