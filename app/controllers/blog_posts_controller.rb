class BlogPostsController < ApplicationController
  # 主要クローラーの User-Agent にマッチする正規表現。閲覧数カウントの除外に使用。
  BOT_PATTERN = /bot|crawl|slurp|spider/i

  def index
    @pagy, @blog_posts = pagy(:offset, BlogPost.published_order.includes(:category), limit: 10)
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
    unless Current.user || BOT_PATTERN.match?(request.user_agent.to_s)
      @blog_post.increment!(:view_count)
    end
  end
end
