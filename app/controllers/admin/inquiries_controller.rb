class Admin::InquiriesController < Admin::BaseController
  before_action :set_inquiry, only: [ :show ]

  def index
    @unread_count = Inquiry.where(read: false).count
    @pagy, @inquiries = pagy(:offset, Inquiry.order(created_at: :desc), limit: 20)
  end

  def show
    @inquiry.update!(read: true)
  end

  private

  def set_inquiry
    @inquiry = Inquiry.find(params[:id])
  end
end
