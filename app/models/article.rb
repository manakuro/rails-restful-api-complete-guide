class Article < ApplicationRecord
  validates_presence_of :title
  validates_presence_of :content
  validates :slug, presence: true, uniqueness: true

  belongs_to :user

  scope :recent, -> { order(created_at: :desc) }
end
