class DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user

  before_action :add_dashboard_breadcrumb

  def show
  end
end
