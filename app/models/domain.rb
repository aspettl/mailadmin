class Domain < ApplicationRecord
  belongs_to :user
  has_many :accounts, dependent: :destroy

  validates :domain, presence: true
end
