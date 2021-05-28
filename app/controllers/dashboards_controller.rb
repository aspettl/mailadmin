require './lib/configreload'

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :get_configreload

  before_action :add_dashboard_breadcrumb

  def show
    @local_domains_count = @user.domains.where(type: Domain.types[:local_domain]).count
    @alias_domains_count = @user.domains.where(type: Domain.types[:alias_domain]).count
    @local_mailboxes_count = @user.accounts.where(type: Account.types[:local_mailbox]).count
    @alias_addresses_count = @user.accounts.where(type: Account.types[:alias_address]).count
    @blackhole_addresses_count = @user.accounts.where(type: Account.types[:blackhole_address]).count

    @mailserver_hostname = GlobalConfiguration::Hostnames.mailserver
    @webmail_hostname = GlobalConfiguration::Hostnames.webmail
    @configreload_configured = @configreload.configured?
  end

  def configreload
    unless @configreload.configured?
      respond_with_error('Configuration reload cannot be triggered, it is not configured.')
      return
    end

    begin
      @configreload.trigger!

      respond_to do |format|
        format.html { redirect_to dashboard_url, notice: "Configuration reload has been triggered." }
        format.json { head :no_content }
      end
    rescue Exception => e
      respond_with_error("Configuration reload failed, an exception occured (#{e.class})")
    end
  end

  private
    def get_configreload
      @configreload = Configreload.new
    end

    def respond_with_error(message)
      respond_to do |format|
        format.html { redirect_to dashboard_url, alert: message }
        format.json { ender json: { error: message }, status: 500 }
      end
    end
end
