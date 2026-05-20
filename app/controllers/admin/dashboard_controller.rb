class Admin::DashboardController < Admin::BaseController
  def index
    @unread_inquiry_count = Inquiry.where(read: false).count
  end
end
