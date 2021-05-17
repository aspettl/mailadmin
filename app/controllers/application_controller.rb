class ApplicationController < ActionController::Base
  private
    def set_user
      @user = current_user
    end
end
