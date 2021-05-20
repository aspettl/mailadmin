class ImportExportApiController < ApplicationController
  BEARER_REGEXP = /\ABearer (.+)\z/i

  before_action :authenticate_via_token!

  # GET /api/backup.json
  def backup
    @domains = Domain.order(:id).all
    @accounts = Account.order(:domain_id, :id).all
  end

  # GET /api/export.json
  def export
    @local_domains = Domain.where(type: Domain.types[:local_domain], enabled: true).order(:id).all
    @alias_domains = Domain.where(type: Domain.types[:alias_domain], enabled: true).order(:id).all
    @local_mailboxes = Account.where(type: Account.types[:local_mailbox], enabled: true).order(:domain_id, :id).all
    @alias_addresses = Account.where(type: Account.types[:alias_address], enabled: true).order(:domain_id, :id).all
    @blackhole_addresses = Account.where(type: Account.types[:blackhole_address], enabled: true).order(:domain_id, :id).all
  end

  private
    def authenticate_via_token!
      required_api_token = ENV['API_TOKEN']
      obtained_api_token = BEARER_REGEXP.match(request.headers['Authorization']) { |m| m[1] }
      if required_api_token.blank?
        render json: { error: "Use of API is not configured." }, status: 500
      else
        render json: { error: "Authorization failed: a valid API token is required." }, status: 401 unless required_api_token == obtained_api_token
      end
    end
end
