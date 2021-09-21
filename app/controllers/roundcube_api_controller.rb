require './lib/configreload'

class RoundcubeApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_account
  before_action :get_configreload

  # POST /api/v1/roundcube_password.txt
  def update_password
    if params[:newpass].blank?
      render plain: 'New password must not be blank! Account password not updated.', status: :bad_request
      return
    end

    @account.password = params[:newpass]
    if @account.save
      render plain: 'OK'

      begin
        @configreload.trigger! unless params[:newpass] == params[:curpass]
      rescue Exception => e
        # nothing sensible that we can do here
      end
    else
      render plain: "Validation failed: #{@account.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_account
    @account = Account.find_by(email: params[:user])
    if @account.nil? or !@account.matches_crypted_password?(params[:curpass])
      render plain: 'Account does not exist or current password is wrong!',
             status: :unauthorized
    end
  end

  def get_configreload
    @configreload = Configreload.new
  end
end
