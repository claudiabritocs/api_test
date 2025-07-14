class Rating < ApplicationRecord
  belongs_to :post
  belongs_to :user

  validates :user, presence: true
  validates :user_id, uniqueness: { scope: :post_id, message: "has already rated this post" }
  validates :post, presence: true
  validates :value, presence: true, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: 5 }
end
