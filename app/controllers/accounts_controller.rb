# frozen_string_literal: true

class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_domain
  before_action :set_account, only: %i[show edit update destroy]

  before_action :add_dashboard_breadcrumb
  before_action :add_domains_breadcrumb
  before_action :add_accounts_breadcrumb
  before_action :add_new_breadcrumb, only: %i[new create]
  before_action :add_show_breadcrumb, only: %i[show edit update]
  before_action :add_edit_breadcrumb, only: %i[edit update]

  # GET /accounts or /accounts.json
  def index
    @accounts = @domain.accounts.order(:email).load
  end

  # GET /accounts/1 or /accounts/1.json
  def show
    @account.known_alias_accounts.load
    @account.known_catchall_domains.load
  end

  # GET /accounts/new
  def new
    @account = Account.new
    @account.email = "@#{@domain.domain}"
    @account.domain = @domain
    @account.enabled = true
  end

  # GET /accounts/1/edit
  def edit
  end

  # POST /accounts or /accounts.json
  def create
    @account = Account.new(new_account_params)
    @account.domain = @domain

    respond_to do |format|
      if @account.save
        format.html { redirect_to [@domain, @account], notice: I18n.t(:account_created, scope: 'messages') }
        format.json { render :show, status: :created, location: [@domain, @account] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /accounts/1 or /accounts/1.json
  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to [@domain, @account], notice: I18n.t(:account_updated, scope: 'messages') }
        format.json { render :show, status: :ok, location: [@domain, @account] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    if @account.can_destroy? || (params[:force] == 'true')
      @account.destroy
      respond_to do |format|
        format.html { redirect_to domain_accounts_url(@domain), notice: I18n.t(:account_destroyed, scope: 'messages') }
        format.json { head :no_content }
      end
    else
      respond_to do |format|
        format.html do
          redirect_to domain_account_url(@domain, @account), alert: I18n.t(:account_not_destroyed, scope: 'messages')
        end
        format.json do
          render json: { error: I18n.t(:account_not_destroyed, scope: 'messages') }, status: :unprocessable_entity
        end
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_domain
    @domain = current_user.domains.find(params[:domain_id])
  end

  def set_account
    @account = @domain.accounts.find(params[:id])
  end

  # Hooks for generation of dynamic breadcrumbs.
  def add_accounts_breadcrumb
    add_breadcrumb @domain.domain, @domain
    add_breadcrumb 'Manage accounts', domain_accounts_path(@domain)
  end

  def add_new_breadcrumb
    add_breadcrumb 'New account', new_domain_account_path(@domain)
  end

  def add_show_breadcrumb
    add_breadcrumb @account.email, [@domain, @account]
  end

  def add_edit_breadcrumb
    add_breadcrumb 'Edit', edit_domain_account_path(@domain, @account)
  end

  # Only allow a list of trusted parameters through.
  def new_account_params
    params.expect(account: %i[type email enabled password forward forward_to alias_target])
  end

  def account_params
    params.expect(account: %i[enabled password forward forward_to alias_target])
  end
end
