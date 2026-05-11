class HomeController < ApplicationController
  def index
    @recent_posts = BlogPost.latest
  end
end
