class DomainsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user
  before_action :set_domain, only: %i[ show edit update destroy ]

  before_action :add_dashboard_breadcrumb
  before_action :add_domains_breadcrumb
  before_action :add_new_breadcrumb, only: %i[ new create ]
  before_action :add_show_breadcrumb, only: %i[ show edit update ]
  before_action :add_edit_breadcrumb, only: %i[ edit update ]

  # GET /domains or /domains.json
  def index
    @domains = current_user.domains.order(:domain).all
  end

  # GET /domains/1 or /domains/1.json
  def show
  end

  # GET /domains/new
  def new
    @domain = Domain.new
    @domain.user = current_user
    @domain.enabled = true
  end

  # GET /domains/1/edit
  def edit
  end

  # POST /domains or /domains.json
  def create
    @domain = Domain.new(new_domain_params)
    @domain.user = current_user

    respond_to do |format|
      if @domain.save
        format.html { redirect_to @domain, notice: "Domain was successfully created." }
        format.json { render :show, status: :created, location: @domain }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /domains/1 or /domains/1.json
  def update
    respond_to do |format|
      if @domain.update(domain_params)
        format.html { redirect_to @domain, notice: "Domain was successfully updated." }
        format.json { render :show, status: :ok, location: @domain }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @domain.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /domains/1 or /domains/1.json
  def destroy
    @domain.destroy
    respond_to do |format|
      format.html { redirect_to domains_url, notice: "Domain was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_domain
      @domain = current_user.domains.find(params[:id])
    end

    # Hooks for generation of dynamic breadcrumbs.
    def add_new_breadcrumb
      add_breadcrumb "New domain", :new_domain_path
    end

    def add_show_breadcrumb
      add_breadcrumb @domain.domain, @domain
    end

    def add_edit_breadcrumb
      add_breadcrumb "Edit", edit_domain_path(@domain)
    end

    # Only allow a list of trusted parameters through.
    def new_domain_params
      params.require(:domain).permit(:domain, :enabled)
    end

    def domain_params
      params.require(:domain).permit(:enabled)
    end
end
