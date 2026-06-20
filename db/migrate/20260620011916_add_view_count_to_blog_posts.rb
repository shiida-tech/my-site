class AddViewCountToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :view_count, :integer, null: false, default: 0
  end
end
