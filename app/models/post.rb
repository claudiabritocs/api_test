class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :title, :body, :ip, presence: true

  attr_accessor :login

  before_validation :assign_user_from_login, if: -> { user.nil? && login.present? }

  scope :best_rated, ->(limit = 5) {
    joins(:ratings)
      .group(:id)
      .select("posts.*, AVG(ratings.value) AS avg_rating")
      .order("avg_rating DESC")
      .limit(limit)
  }

  def rating_average(new_value)
    existing_sum = ratings.sum(:value)
    existing_count = ratings.count
    ((existing_sum + new_value) / (existing_count + 1).to_f).round(2)
  end

  private

  def assign_user_from_login
    self.user = User.find_or_create_by(login: login)
  end
end
