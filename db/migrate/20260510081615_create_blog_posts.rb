class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.datetime :published_at
      t.references :category, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :blog_posts, :slug, unique: true
    add_index :blog_posts, :status
    add_index :blog_posts, :published_at
  end
end
