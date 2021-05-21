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

    cattr_accessor :token
  end
end
