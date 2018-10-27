class User < ApplicationRecord
  include BCrypt

  validates :login, presence: true, uniqueness: true
  validates :provider, presence: true
  validates :password, presence: true, if: :standard_provider?

  has_one :access_token, dependent: :destroy
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy

  def password
    @password ||= Password.new(encryped_password) if encryped_password.present?
  end

  def password=(new_password)
    return @password = new_password if new_password.blank?

    @password = Password.create(new_password)
    self.encryped_password = @password
  end

  def standard_provider?
    provider == 'standard'
  end
end
