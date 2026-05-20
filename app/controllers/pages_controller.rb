class PagesController < ApplicationController
  def index
    @recent_posts = BlogPost.latest
  end

  def privacy_policy
  end
end
