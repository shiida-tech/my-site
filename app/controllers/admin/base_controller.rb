class Admin::BaseController < ApplicationController
  include Authentication

  before_action :require_admin

  layout "admin"

  private

  def require_admin
    redirect_to root_path, alert: "アクセス権限がありません。" unless Current.user&.admin?
  end
end
