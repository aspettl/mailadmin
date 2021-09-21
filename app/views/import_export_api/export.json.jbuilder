# frozen_string_literal: true

json.domains @local_domains.map(&:domain)

json.domain_aliases @alias_domains.map { |domain| [domain.domain, domain.alias_target] }.to_h

json.domain_catchalls @local_domains.filter(&:catchall).map { |domain| [domain.domain, domain.catchall_target] }.to_h

json.mailbox_passwords @local_mailboxes.map { |account| [account.email, account.crypt] }.to_h

aliases1 = @local_mailboxes.filter(&:forward).map { |account| [account.email, account.forward_to] }
aliases2 = @alias_addresses.map { |account| [account.email, account.alias_target] }
json.mailbox_aliases (aliases1 + aliases2).to_h

json.mailbox_drop @blackhole_addresses.map(&:email)
