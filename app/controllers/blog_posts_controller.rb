class BlogPostsController < ApplicationController
  def index
    @pagy, @blog_posts = pagy(:offset, BlogPost.published_order.includes(:category), limit: 10)
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
  end
end
