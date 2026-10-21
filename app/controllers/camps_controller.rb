class CampsController < ApplicationController
  before_action :require_admin, only: %i[index]

  def index
    @camps = Camp.order(active: :desc, name: :asc)
  end
end
