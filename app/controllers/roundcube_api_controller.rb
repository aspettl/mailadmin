# frozen_string_literal: true

require './lib/configreload'

class RoundcubeApiController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_account
  before_action :use_configreload
  before_action :require_new_password

  # POST /api/v1/roundcube_password.txt
  def update_password
    @account.password = params[:newpass]
    if @account.save
      render plain: 'OK'

      begin
        @configreload.trigger! unless params[:newpass] == params[:curpass]
      rescue StandardError
        # nothing sensible that we can do here
      end
    else
      render plain: "Validation failed: #{@account.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_account
    @account = Account.find_by(email: params[:user])

    return unless @account.nil? || !@account.matches_crypted_password?(params[:curpass])

    render plain: 'Account does not exist or current password is wrong!',
           status: :unauthorized
  end

  def use_configreload
    @configreload = Configreload.new
  end

  def require_new_password
    return if params[:newpass].present?

    render plain: 'New password must be specified! Account password not updated.', status: :bad_request
  end
end
