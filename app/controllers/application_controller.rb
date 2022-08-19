# frozen_string_literal: true

class ApplicationController < ActionController::Base
  private

  def set_user
    @user = user_signed_in? ? current_user : nil
    @login_via_http_auth = (request.headers['Authorization'] || '').downcase.start_with?('basic ')
  end

  def add_dashboard_breadcrumb
    add_breadcrumb 'Dashboard', :root_path
  end

  def add_domains_breadcrumb
    add_breadcrumb 'Manage domains', :domains_path
  end

  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
