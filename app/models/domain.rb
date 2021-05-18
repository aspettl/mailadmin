class Domain < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  validates :user_id, presence: true
  validates :domain, uniqueness: true, format: { with: /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,10}\Z/ix }, length: { maximum: 255 }
  validates :enabled, inclusion: { in: [ true, false ] }
end
