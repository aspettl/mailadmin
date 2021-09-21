require 'bcrypt'
require 'memoist'

class Account < ApplicationRecord
  extend Memoist

  EMAIL_REGEXP = /\A[a-zA-Z0-9.+=_~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/
  MODERN_CRYPT_METHODS = %w[SHA256-CRYPT SHA512-CRYPT BCRYPT ARGON2]

  belongs_to :domain

  enum type: { local_mailbox: 0, alias_address: 1, blackhole_address: 2 }

  attr_accessor :password

  validates :type, inclusion: { in: types.keys }
  validates :email, uniqueness: true, format: { with: EMAIL_REGEXP }, length: { maximum: 255 }
  validates_each :email do |record, attr, value|
    unless value.ends_with?("@#{record.domain.domain}")
      record.errors.add(attr,
                        'must be an account under the currently selected domain name')
    end
  end
  validates :password, presence: { on: :create, unless: :crypt? },
                       length: { minimum: 10, allow_blank: true, unless: :password_unchanged? }, not_pwned: { unless: :password_unchanged? }, if: :local_mailbox?
  validates :password, inclusion: { in: [nil, ''], message: 'must be empty when this is an alias address' },
                       unless: :local_mailbox?
  validates :forward_to, presence: { if: :forward }, format: { with: EMAIL_REGEXP, allow_blank: true },
                         length: { maximum: 255 }, if: :local_mailbox?
  validates :forward_to, inclusion: { in: [nil, ''], message: 'must be empty when this is an alias address' },
                         unless: :local_mailbox?
  validates :alias_target, presence: true, length: { maximum: 255 }, if: :alias_address?
  validates_each :alias_target, allow_blank: true, if: :alias_address? do |record, attr, value|
    targets = value.split(',', 50)
    record.errors.add(attr, 'is invalid') if targets.any? { |element| !element.match?(EMAIL_REGEXP) }
    record.errors.add(attr, 'must not redirect to itself') if targets.any? { |element| element == record.email }
  end
  validates :alias_target, inclusion: { in: [nil, ''], message: 'must be empty when this is not an alias address' },
                           unless: :alias_address?

  before_save :crypt_password

  def crypt_hash_method
    if !crypt
      nil
    elsif crypt.length == 13
      'DES-CRYPT'
    elsif crypt.starts_with?('$1')
      'MD5-CRYPT'
    elsif crypt.starts_with?('$5')
      'SHA256-CRYPT'
    elsif crypt.starts_with?('$6')
      'SHA512-CRYPT'
    elsif crypt.starts_with?('$2')
      'BCRYPT'
    elsif crypt.starts_with?('$argon2')
      'ARGON2'
    else
      :unknown
    end
  end

  def matches_crypted_password?(password)
    return false if password.blank? or crypt.blank?

    password.crypt(crypt) == crypt
  end

  def password_unchanged?
    matches_crypted_password?(password)
  end

  def known_alias_accounts
    Account.where(type: Account.types[:local_mailbox], enabled: true, forward: true, forward_to: email)
           .or(Account.where(type: Account.types[:alias_address], enabled: true, alias_target: email)).order(:email)
  end
  memoize :known_alias_accounts

  def known_catchall_domains
    Domain.where(type: Domain.types[:local_domain], enabled: true, catchall: true,
                 catchall_target: email).order(:domain)
  end
  memoize :known_catchall_domains

  def can_destroy?
    known_alias_accounts.empty? and known_catchall_domains.empty?
  end

  private

  def crypt_password
    unless password.blank? or (crypt_hash_method == 'BCRYPT' and password_unchanged?)
      self.crypt = BCrypt::Password.create(password)
    end
  end
end
