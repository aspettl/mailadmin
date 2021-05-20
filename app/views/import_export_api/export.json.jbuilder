json.domains @local_domains.map { |domain| domain.domain }
json.domain_aliases Hash[@alias_domains.map{ |domain| [ domain.domain, domain.alias_target ] }]
json.domain_catchalls Hash[@local_domains.filter{ |domain| domain.catchall }.map{ |domain| [ domain.domain, domain.catchall_target ] }]
json.mailbox_passwords Hash[@local_mailboxes.map{ |account| [ account.email, account.crypt ] }]
json.mailbox_aliases Hash[@local_mailboxes.filter{ |account| account.forward }.map{ |account| [ account.email, account.forward_to ] } + @alias_addresses.filter{ |account| !account.alias_target.include?(',') }.map{ |account| [ account.email, account.alias_target ] }]
json.group_aliases Hash[@alias_addresses.filter{ |account| account.alias_target.include?(',') }.map{ |account| [ account.email, account.alias_target.split(',') ] }]
json.mailbox_drop @blackhole_addresses.map{ |account| account.email }