class Domain < ApplicationRecord
  DOMAIN_REGEXP = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,10}\z/ix

  belongs_to :user
  has_many :accounts, dependent: :destroy

  enum type: { local_domain: 0, alias_domain: 1 }

  validates :user_id, presence: true
  validates :type, inclusion: { in: types.keys }
  validates :domain, uniqueness: true, format: { with: DOMAIN_REGEXP }, length: { maximum: 255 }
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :alias_target, format: { with: DOMAIN_REGEXP }, length: { maximum: 255 }, if: :alias_domain?
  validates :alias_target, inclusion: { in: [ nil, '' ], message: 'must be empty when this is not an alias domain' }, unless: :alias_domain?
end
