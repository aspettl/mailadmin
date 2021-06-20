require 'bcrypt'
require 'memoist'

class Account < ApplicationRecord
  extend Memoist

  EMAIL_REGEXP = /\A[a-zA-Z0-9.+=_~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
  MODERN_CRYPT_METHODS = ['SHA256-CRYPT', 'SHA512-CRYPT', 'BCRYPT', 'ARGON2']

  belongs_to :domain

  enum type: { local_mailbox: 0, alias_address: 1, blackhole_address: 2 }

  attr_accessor :password

  validates :type, inclusion: { in: types.keys }
  validates :email, uniqueness: true, format: { with: EMAIL_REGEXP }, length: { maximum: 255 }
  validates_each :email do |record, attr, value|
    record.errors.add(attr, 'must be an account under the currently selected domain name') unless value.ends_with?("@#{record.domain.domain}")
  end
  validates :password, presence: { on: :create, unless: :crypt? }, length: { minimum: 10, allow_blank: true, unless: :password_unchanged? }, not_pwned: { unless: :password_unchanged? }, if: :local_mailbox?
  validates :password, inclusion: { in: [ nil, '' ], message: 'must be empty when this is an alias address' }, unless: :local_mailbox?
  validates :forward_to, presence: { if: :forward }, format: { with: EMAIL_REGEXP, allow_blank: true }, length: { maximum: 255 }, if: :local_mailbox?
  validates :forward_to, inclusion: { in: [ nil, '' ], message: 'must be empty when this is an alias address' }, unless: :local_mailbox?
  validates :alias_target, presence: true, length: { maximum: 255 }, if: :alias_address?
  validates_each :alias_target, :allow_blank => true, if: :alias_address? do |record, attr, value|
    targets = value.split(',', 50)
    record.errors.add(attr, 'is invalid') if targets.any? { |element| !element.match?(EMAIL_REGEXP) }
    record.errors.add(attr, 'must not redirect to itself') if targets.any? { |element| element == record.email }
  end
  validates :alias_target, inclusion: { in: [ nil, '' ], message: 'must be empty when this is not an alias address' }, unless: :alias_address?

  before_save :crypt_password

  def crypt_hash_method
    if !self.crypt
      nil
    elsif self.crypt.length == 13
      'DES-CRYPT'
    elsif self.crypt.starts_with?('$1')
      'MD5-CRYPT'
    elsif self.crypt.starts_with?('$5')
      'SHA256-CRYPT'
    elsif self.crypt.starts_with?('$6')
      'SHA512-CRYPT'
    elsif self.crypt.starts_with?('$2')
      'BCRYPT'
    elsif self.crypt.starts_with?('$argon2')
      'ARGON2'
    else
      :unknown
    end
  end

  def matches_crypted_password?(password)
    return false if password.blank? or self.crypt.blank?
    password.crypt(self.crypt) == self.crypt
  end

  def password_unchanged?
    self.matches_crypted_password?(self.password)
  end

  def known_alias_accounts
    Account.where(type: Account.types[:local_mailbox], enabled: true, forward: true, forward_to: self.email)
      .or(Account.where(type: Account.types[:alias_address], enabled: true, alias_target: self.email)).order(:email)
  end
  memoize :known_alias_accounts

  def known_catchall_domains
    Domain.where(type: Domain.types[:local_domain], enabled: true, catchall: true, catchall_target: self.email).order(:domain)
  end
  memoize :known_catchall_domains

  def can_destroy?
    self.known_alias_accounts.empty? and self.known_catchall_domains.empty?
  end

  private
    def crypt_password
      self.crypt = BCrypt::Password.create(self.password) unless self.password.blank? or (self.crypt_hash_method == 'BCRYPT' and self.password_unchanged?)
    end
end
