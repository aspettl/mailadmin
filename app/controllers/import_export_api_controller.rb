class ImportExportApiController < ApplicationController
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
end
