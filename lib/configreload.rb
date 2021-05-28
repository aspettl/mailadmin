class Configreload
  def initialize(webhook_url = GlobalConfiguration::API.configreload_webhook)
    @webhook_uri = if webhook_url.blank?
                     nil
                   else
                     URI(webhook_url)
                   end
  end

  def configured?
    @webhook_uri.present?
  end

  def trigger!
    Net::HTTP.get_response(@webhook_uri) if self.configured?
    self.configured?
  end
end