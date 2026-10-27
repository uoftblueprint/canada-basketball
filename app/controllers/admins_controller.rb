class AdminsController < ApplicationController
  before_action :require_admin

  def index
    @admins = Admin.order(:name)
  end
end
