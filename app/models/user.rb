class User < ApplicationRecord
  has_many :posts
  has_many :ratings

  validates :login, presence: true, uniqueness: true
  validates :login, format: {
    with: /\A[a-zA-Z0-9@_.-]+\z/,
    message: "only allows letters, numbers, underscores, dots and dashes"
  }

  scope :ips_and_users, -> {
    joins(:posts)
    .select("posts.ip AS ip, array_agg(DISTINCT users.login) AS logins")
    .group("posts.ip")
  }
end
