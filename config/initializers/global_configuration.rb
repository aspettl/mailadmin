require 'socket'

module GlobalConfiguration
  class Hostnames
    @@mailserver = ENV.fetch('MAILSERVER_HOSTNAME') { Socket.gethostname }
    @@webmail = ENV.fetch('WEBMAIL_HOSTNAME', @@mailserver)

    cattr_accessor :mailserver
    cattr_accessor :webmail
  end

  class API
    @@token = ENV.fetch('API_TOKEN', nil)
    @@configreload_webhook = ENV.fetch('CONFIGRELOAD_WEBHOOK', nil)

    cattr_accessor :token
    cattr_accessor :configreload_webhook
  end
end
