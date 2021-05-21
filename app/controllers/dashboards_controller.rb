class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  before_action :add_dashboard_breadcrumb

  def show
    @local_domains_count = @user.domains.where(type: Domain.types[:local_domain]).count
    @alias_domains_count = @user.domains.where(type: Domain.types[:alias_domain]).count
    @local_mailboxes_count = @user.accounts.where(type: Account.types[:local_mailbox]).count
    @alias_addresses_count = @user.accounts.where(type: Account.types[:alias_address]).count
    @blackhole_addresses_count = @user.accounts.where(type: Account.types[:blackhole_address]).count

    @mailserver_hostname = GlobalConfiguration::Hostnames.mailserver
    @webmail_hostname = GlobalConfiguration::Hostnames.webmail
  end
end
