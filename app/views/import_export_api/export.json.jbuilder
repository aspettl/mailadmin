json.domains @local_domains.map { |domain| domain.domain }
json.domain_aliases @alias_domains.map { |domain| [domain.domain, domain.alias_target] }.to_h
json.domain_catchalls @local_domains.filter do |domain|
  domain.catchall
end.map { |domain| [domain.domain, domain.catchall_target] }.to_h
json.mailbox_passwords @local_mailboxes.map { |account| [account.email, account.crypt] }.to_h
json.mailbox_aliases (@local_mailboxes.filter do |account|
  account.forward
end.map { |account| [account.email, account.forward_to] } + @alias_addresses.map do |account|
                                                              [account.email,
                                                               account.alias_target]
                                                            end).to_h
json.mailbox_drop @blackhole_addresses.map { |account| account.email }
