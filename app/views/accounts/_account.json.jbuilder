json.extract! account, :id, :email, :domain_id, :enabled, :created_at, :updated_at
json.url domain_account_url(account.domain, account, format: :json)
