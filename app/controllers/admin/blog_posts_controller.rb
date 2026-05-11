class Admin::BlogPostsController < Admin::BaseController
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish, :preview]

  def index
    @pagy, @blog_posts = pagy(:offset, BlogPost.includes(:category, :user).order(id: :desc), limit: 20)
  end

  def show
  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.user = Current.user
    if @blog_post.save
      redirect_to admin_blog_post_path(@blog_post), notice: "記事を作成しました。"
    else
      render :new, status: :unprocessable_content
    end
  end

  def edit
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_post_path(@blog_post), notice: "記事を更新しました。"
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "記事を削除しました。", status: :see_other
  end

  def publish
    @blog_post.publish!
    redirect_to admin_blog_post_path(@blog_post), notice: "記事を公開しました。"
  end

  def unpublish
    @blog_post.unpublish!
    redirect_to admin_blog_post_path(@blog_post), notice: "記事を非公開にしました。"
  end

  def preview
    render "blog_posts/show", layout: "application", locals: { preview_mode: true }
  end

  private

  def set_blog_post
    @blog_post = BlogPost.find(params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :category_id, :content)
  end
end
