require 'memoist'

class Domain < ApplicationRecord
  extend Memoist

  DOMAIN_REGEXP = /\A[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,10}\z/ix

  belongs_to :user
  has_many :accounts, dependent: :destroy

  enum type: { local_domain: 0, alias_domain: 1 }

  validates :user_id, presence: true
  validates :type, inclusion: { in: types.keys }
  validates :domain, uniqueness: true, format: { with: DOMAIN_REGEXP }, length: { maximum: 255 }
  validates_each :domain, on: :create do |record, attr, value|
    parts = (value || '').split('.')
    (1...parts.length).each do |start|
      domain = parts[start..].join('.')
      record.errors.add(attr, "is a subdomain of already existing '#{domain}' from a different user") unless Domain.where(domain: domain).where.not(user_id: record.user_id).empty?
    end
  end
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :catchall, inclusion: { in: [ true, false ] }
  validates :catchall_target, presence: { if: :catchall }, format: { with: Account::EMAIL_REGEXP, allow_blank: true }, length: { maximum: 255 }, if: :local_domain?
  validates :catchall_target, inclusion: { in: [ nil, '' ], message: 'must be empty when this is an alias domain' }, unless: :local_domain?
  validates :alias_target, format: { with: DOMAIN_REGEXP }, length: { maximum: 255 }, if: :alias_domain?
  validates :alias_target, inclusion: { in: [ nil, '' ], message: 'must be empty when this is not an alias domain' }, unless: :alias_domain?

  def known_alias_domains
    Domain.where(type: Domain.types[:alias_domain], enabled: true, alias_target: self.domain).order(:domain)
  end
  memoize :known_alias_domains

  def can_destroy?
    self.accounts.empty? and self.known_alias_domains.empty?
  end
end
