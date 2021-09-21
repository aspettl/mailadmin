json.extract! account, :id, :type, :domain_id, :email, :enabled, :forward, :forward_to, :alias_target, :created_at,
              :updated_at
json.url domain_account_url(account.domain, account, format: :json)
