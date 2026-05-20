class InquiriesController < ApplicationController
  def new
    @inquiry = Inquiry.new
  end

  def create
    # ハニーポット：ボットは非表示フィールドにも入力するため、値があればスパムとして無視する
    if params.dig(:inquiry, :phone).present?
      redirect_to root_path, notice: "送信しました。"
      return
    end

    @inquiry = Inquiry.new(inquiry_params)
    if @inquiry.save
      InquiryMailer.notification(@inquiry).deliver_later
      redirect_to root_path, notice: "お問い合わせを受け付けました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:name, :email, :company_name, :body)
  end
end
