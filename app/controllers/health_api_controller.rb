class HealthApiController < ApplicationController
  # GET /api/v1/health.json
  def show
    render json: { health: "OK" }
  end
end
