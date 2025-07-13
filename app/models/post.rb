class Post < ApplicationRecord
  belongs_to :user
  has_many :ratings

  validates :title, :body, :ip, presence: true

  attr_accessor :login

  before_validation :assign_user_from_login, if: -> { user.nil? && login.present? }

  private

  def assign_user_from_login
    self.user = User.find_or_create_by(login: login)
  end
end
