require 'socket'

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  before_action :add_dashboard_breadcrumb

  def show
    @domains_count = @user.domains.count
    @local_accounts_count = @user.accounts.where(forward: false).count
    @forwarding_accounts_count = @user.accounts.where(forward: true).count

    @mailserver_hostname = ENV['MAILSERVER_HOSTNAME'] || Socket.gethostname
  end
end
