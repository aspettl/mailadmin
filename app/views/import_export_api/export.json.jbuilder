# frozen_string_literal: true

json.domains(@local_domains.map(&:domain))

json.domain_aliases(@alias_domains.to_h { |domain| [domain.domain, domain.alias_target] })

json.domain_catchalls(@local_domains.filter(&:catchall).to_h { |domain| [domain.domain, domain.catchall_target] })

json.mailbox_passwords(@local_mailboxes.to_h { |account| [account.email, account.crypt] })

aliases1 = @local_mailboxes.filter(&:forward).map { |account| [account.email, account.forward_to] }
aliases2 = @alias_addresses.map { |account| [account.email, account.alias_target] }
json.mailbox_aliases((aliases1 + aliases2).to_h)

json.mailbox_drop(@blackhole_addresses.map(&:email))
