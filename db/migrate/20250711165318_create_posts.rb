class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |post|
      post.references :user, null: false, foreign_key: true
      post.string :title, null: false
      post.text :body, null: false
      post.string :ip, null: false

      post.timestamps
    end
  end
end
