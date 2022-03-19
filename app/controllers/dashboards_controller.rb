# frozen_string_literal: true

require './lib/configreload'

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :use_configreload

  before_action :add_dashboard_breadcrumb

  def show # rubocop:disable Metrics/AbcSize
    @local_domains_count = @user.domains.where(type: Domain.types[:local_domain]).count
    @alias_domains_count = @user.domains.where(type: Domain.types[:alias_domain]).count
    @local_mailboxes_count = @user.accounts.where(type: Account.types[:local_mailbox]).count
    @alias_addresses_count = @user.accounts.where(type: Account.types[:alias_address]).count
    @blackhole_addresses_count = @user.accounts.where(type: Account.types[:blackhole_address]).count

    @mailserver_hostname = Rails.configuration.mailserver_hostname
    @webmail_hostname = Rails.configuration.webmail_hostname
    @configreload_configured = @configreload.configured?
  end

  def configreload
    unless @configreload.configured?
      respond_with_error(I18n.t(:configreload_not_configured, scope: :messages))
      return
    end

    begin
      @configreload.trigger!

      respond_to do |format|
        format.html { redirect_to dashboard_url, notice: I18n.t(:configreload_triggered, scope: :messages) }
        format.json { head :no_content }
      end
    rescue StandardError => e
      respond_with_error(I18n.t(:configreload_exception, exception_class: e.class, scope: :messages))
    end
  end

  private

  def use_configreload
    @configreload = Configreload.new
  end

  def respond_with_error(message)
    respond_to do |format|
      format.html { redirect_to dashboard_url, alert: message }
      format.json { ender json: { error: message }, status: 500 }
    end
  end
end
