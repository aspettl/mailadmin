class RoundcubeApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_account

  # POST /api/v1/roundcube_password.txt
  def update_password
    if params[:new_password].blank?
      render plain: 'New password must not be blank! Account password not updated.', status: 400
      return
    end

    @account.password = params[:new_password]
    if @account.save
      render plain: 'Account password has been updated.', status: 200

      begin
        Net::HTTP.get_response(URI(GlobalConfiguration::API.configreload_webhook)) unless GlobalConfiguration::API.configreload_webhook.blank?
      rescue Exception => e
        # nothing sensible that we can do here
      end
    else
      render plain: 'Validation failed! Account password not updated.', status: 400
    end
  end

  private
    def set_account
      @account = Account.find_by(email: params[:email])
      render plain: "Account does not exist or current password is wrong!", status: 401 if @account.nil? or !@account.matches_crypted_password?(params[:current_password])
    end
end
