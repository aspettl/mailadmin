class AccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_domain
  before_action :set_account, only: %i[ show edit update destroy ]

  # GET /accounts or /accounts.json
  def index
    @accounts = @domain.accounts.all
  end

  # GET /accounts/1 or /accounts/1.json
  def show
  end

  # GET /accounts/new
  def new
    @account = Account.new
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
        format.html { redirect_to [@domain, @account], notice: "Account was successfully created." }
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
        format.html { redirect_to [@domain, @account], notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: [@domain, @account] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /accounts/1 or /accounts/1.json
  def destroy
    @account.destroy
    respond_to do |format|
      format.html { redirect_to domain_accounts_url(@domain), notice: "Account was successfully destroyed." }
      format.json { head :no_content }
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

    # Only allow a list of trusted parameters through.
    def new_account_params
      params.require(:account).permit(:email, :crypt, :enabled)
    end

    def account_params
      params.require(:account).permit(:crypt, :enabled)
    end
end
