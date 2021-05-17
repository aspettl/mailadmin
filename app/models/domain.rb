class Domain < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  validates :domain, format: { with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,10}\Z/ix }
  validates :domain, uniqueness: true
  validates :user_id, presence: true
end
