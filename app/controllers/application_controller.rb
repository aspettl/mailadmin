class ApplicationController < ActionController::Base
  private
    def set_user
      @user = current_user
      @login_via_http_auth = (request.headers['Authorization'] || '').downcase.start_with?('basic ')
    end

    def add_dashboard_breadcrumb
      add_breadcrumb "Dashboard", :root_path
    end

    def add_domains_breadcrumb
      add_breadcrumb "Manage domains", :domains_path
    end
end
