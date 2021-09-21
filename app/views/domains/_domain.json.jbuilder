json.extract! domain, :id, :type, :domain, :enabled, :catchall, :catchall_target, :alias_target, :created_at,
              :updated_at
json.url domain_url(domain, format: :json)
