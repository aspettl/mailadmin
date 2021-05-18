class Account < ApplicationRecord
  EMAIL_REGEXP = /\A[a-zA-Z0-9.+=_~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/

  belongs_to :domain

  enum type: { local_mailbox: 0, alias_address: 1, blackhole_address: 2 }

  attr_accessor :password

  validates :type, inclusion: { in: types.keys }
  validates :domain_id, presence: true
  validates :email, uniqueness: true, format: { with: EMAIL_REGEXP }, length: { maximum: 255 }
  validates_each :email do |record, attr, value|
    record.errors.add(attr, 'must be an account under the currently selected domain name') unless value.ends_with?("@#{record.domain.domain}")
  end
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :password, presence: { on: :create }, length: { minimum: 10, allow_blank: true }, if: :local_mailbox?
  validates :password, inclusion: { in: [ nil, '' ], message: 'must be empty when this is an alias address' }, unless: :local_mailbox?
  validates :forward, inclusion: { in: [ true, false ] }
  validates :forward_to, presence: { if: :forward }, format: { with: EMAIL_REGEXP, allow_blank: true }, length: { maximum: 255 }, if: :local_mailbox?
  validates :forward_to, inclusion: { in: [ nil, '' ], message: 'must be empty when this is an alias address' }, unless: :local_mailbox?
  validates :alias_target, presence: true, length: { maximum: 255 }, if: :alias_address?
  validates_each :alias_target, :allow_blank => true, if: :alias_address? do |record, attr, value|
    record.errors.add(attr, 'is invalid') unless value.split(',', 50).all? { |element| element.match?(EMAIL_REGEXP) }
  end
  validates :alias_target, inclusion: { in: [ nil, '' ], message: 'must be empty when this is not an alias address' }, unless: :alias_address?

  before_save :crypt_password

  def crypt_hash_method
    if !self.crypt
      nil
    elsif self.crypt.starts_with?('$1')
      'MD5-CRYPT'
    elsif self.crypt.starts_with?('$6')
      'SHA512-CRYPT'
    else
      'DES-CRYPT'
    end
  end

  private
    def crypt_password
      self.crypt = sha512crypt(password) unless password.blank?
    end

    def sha512crypt(password)
      salt = SecureRandom.hex(8)
      password.crypt('$6$' + salt)
    end
end
