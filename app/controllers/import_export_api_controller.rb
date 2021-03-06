# frozen_string_literal: true

class ImportExportApiController < ApplicationController # rubocop:disable Metrics/ClassLength
  BEARER_REGEXP = /\ABearer (.+)\z/i

  skip_before_action :verify_authenticity_token
  before_action :authenticate_via_token!

  # GET /api/v1/backup.json
  def backup
    @domains = Domain.order(:id).all
    @accounts = Account.order(:domain_id, :id).all
  end

  # GET /api/v1/export.json
  def export # rubocop:disable Metrics/AbcSize
    @local_domains = Domain.where(type: Domain.types[:local_domain], enabled: true).order(:id).all
    @alias_domains = Domain.where(type: Domain.types[:alias_domain], enabled: true).order(:id).all
    @local_mailboxes = Account.where(type: Account.types[:local_mailbox], enabled: true).order(:domain_id, :id).all
    @alias_addresses = Account.where(type: Account.types[:alias_address], enabled: true).order(:domain_id, :id).all
    @blackhole_addresses = Account.where(type: Account.types[:blackhole_address], enabled: true)
                                  .order(:domain_id, :id).all
  end

  # POST /api/v1/import.json
  def import # rubocop:disable Metrics
    catch(:abort) do # rubocop:disable Metrics/BlockLength
      user = User.find_by(email: params[:user])
      render_error("User with email address #{params[:user]} does not exist!") if user.nil?

      (params[:domains] || []).each do |domain_name|
        domain = user.domains.find_by(domain: domain_name)
        if domain.present?
          unless domain.local_domain?
            render_error("Local domain #{domain_name} cannot be imported, it already exists with a different type!")
          end
          unless domain.enabled
            render_error("Local domain #{domain_name} cannot be imported, it already exists but it is disabled!")
          end
        else
          Domain.create!(user:, type: Domain.types[:local_domain], domain: domain_name, enabled: true)
        end
      end

      (params[:domain_aliases] || {}).each do |domain_name, alias_target|
        domain = user.domains.find_by(domain: domain_name)
        if domain.present?
          unless domain.alias_domain?
            render_error("Alias domain #{domain_name} cannot be imported, it already exists with a different type!")
          end
          unless domain.alias_target == alias_target
            render_error("Alias domain #{domain_name} cannot be imported, it already exists with a different target!")
          end
          unless domain.enabled
            render_error("Alias domain #{domain_name} cannot be imported, it already exists but it is disabled!")
          end
        else
          Domain.create!(user:, type: Domain.types[:alias_domain], domain: domain_name, enabled: true,
                         alias_target:)
        end
      end

      (params[:domain_catchalls] || {}).each do |domain_name, catchall_target|
        domain = user.domains.find_by(domain: domain_name, type: Domain.types[:local_domain])
        if domain.present?
          domain.catchall = true
          domain.catchall_target = catchall_target
          domain.save!
        else
          render_error("No local domain #{domain_name} found, cannot set catchall address!")
        end
      end

      (params[:mailbox_passwords] || {}).each do |email, crypt|
        domain = find_local_domain_by_email(user, email)
        account = domain.accounts.find_by(email:)
        if account.present?
          unless account.local_mailbox?
            render_error("Account #{email} found, but it is not a local mailbox, cannot set password!")
          end
          account.crypt = crypt
          account.save!
        else
          Account.create!(domain:, type: Account.types[:local_mailbox], email:, enabled: true,
                          crypt:)
        end
      end

      (params[:mailbox_aliases] || {}).each do |email, alias_target|
        domain = find_local_domain_by_email(user, email)
        account = domain.accounts.find_by(email:)
        if account.present?
          if account.local_mailbox?
            account.forward = true
            account.forward_to = alias_target
            account.save!
          elsif account.alias_address?
            account.alias_target = alias_target
            account.save!
          else
            render_error("Account #{email} found, but it is not a local mailbox or alias address, " \
                         'cannot set forwarding target!')
          end
        else
          Account.create!(domain:, type: Account.types[:alias_address], email:, enabled: true,
                          alias_target:)
        end
      end

      (params[:mailbox_drop] || []).each do |email|
        domain = find_local_domain_by_email(user, email)
        account = domain.accounts.find_by(email:)
        if account.present?
          render_error("Account #{email} found, but it is not a blackhole address!") unless account.blackhole_address?
        else
          Account.create!(domain:, type: Account.types[:blackhole_address], email:, enabled: true)
        end
      end

      render json: { success: 'All records have been imported.' }, status: :ok
    end
  end

  private

  def authenticate_via_token!
    required_api_token = Rails.configuration.api_token
    obtained_api_token = BEARER_REGEXP.match(request.headers['Authorization']) { |m| m[1] }
    if required_api_token.blank?
      render_error('Use of API is not configured.', status: 500, abort: false)
    else
      unless required_api_token == obtained_api_token
        render_error('Authorization failed: a valid API token is required.', status: 401, abort: false)
      end
    end
  end

  def render_error(message, status: 400, abort: true)
    render status:, json: { error: message }
    throw(:abort) if abort
  end

  def find_local_domain_by_email(user, email)
    domain_name = email.split('@', 2)[1]
    domain = user.domains.find_by(domain: domain_name, type: Domain.types[:local_domain])
    render_error("No local domain #{domain_name} found, required for account #{email}!") if domain.nil?
    domain
  end
end
