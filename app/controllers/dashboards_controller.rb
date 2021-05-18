require 'socket'

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  before_action :add_dashboard_breadcrumb

  def show
    @domains_count = @user.domains.count
    @local_accounts_count = @user.accounts.where(type: Account.types[:local_mailbox]).count
    @forwarding_accounts_count = @user.accounts.where(type: Account.types[:alias_address]).count

    @mailserver_hostname = ENV['MAILSERVER_HOSTNAME'] || Socket.gethostname
  end
end
