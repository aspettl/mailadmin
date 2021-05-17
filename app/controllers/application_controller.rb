class ApplicationController < ActionController::Base
  private
    def set_user
      @user = current_user
    end

    def add_dashboard_breadcrumb
      add_breadcrumb "Dashboard", :root_path
    end

    def add_domains_breadcrumb
      add_breadcrumb "Manage domains", :domains_path
    end
end
