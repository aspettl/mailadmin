# frozen_string_literal: true

require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Mailadmin
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Avoid password fields of Roundcube password plugin API in logs
    config.filter_parameters += %i[curpass newpass]

    # Do not use encrypted secrets, the application is delivered as a public docker image.
    # But we still need to set secret_key_base.
    config.secret_key_base = ENV.fetch('SECRET_KEY_BASE') do
      puts 'Environment variable SECRET_KEY_BASE is not set, using a random value!'
      SecureRandom.hex(64)
    end

    # Custom application configuration
    config.mailserver_hostname  = ENV.fetch('MAILSERVER_HOSTNAME') { Socket.gethostname }
    default_mx_record           = "@   3600    IN  MX  10  #{config.mailserver_hostname}."
    default_spf_record          = "@   3600    IN  TXT     \"v=spf1 include:#{config.mailserver_hostname} ~all\""
    config.mx_record            = ENV.fetch('MX_RECORD', default_mx_record)
    config.spf_record           = ENV.fetch('SPF_RECORD', default_spf_record)
    config.smtp_hostname        = ENV.fetch('SMTP_HOSTNAME', config.mailserver_hostname)
    config.pop3_hostname        = ENV.fetch('POP3_HOSTNAME', config.mailserver_hostname)
    config.imap_hostname        = ENV.fetch('IMAP_HOSTNAME', config.mailserver_hostname)
    config.managesieve_hostname = ENV.fetch('MANAGESIEVE_HOSTNAME', config.mailserver_hostname)
    config.webmail_hostname     = ENV.fetch('WEBMAIL_HOSTNAME', config.mailserver_hostname)
    config.api_token            = ENV.fetch('API_TOKEN', nil)
    config.configreload_webhook = ENV.fetch('CONFIGRELOAD_WEBHOOK', nil)
  end
end
