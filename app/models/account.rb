class Account < ApplicationRecord
  belongs_to :domain

  attr_accessor :password

  validates :domain_id, presence: true
  validates :email, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 255 }
  validates_each :email do |record, attr, value|
    record.errors.add(attr, 'must be an account under the currently selected domain name') unless value.ends_with?("@#{record.domain.domain}")
  end
  validates :enabled, inclusion: { in: [ true, false ] }
  validates :password, presence: { on: :create }, length: { minimum: 10, allow_blank: true }
  validates :forward, inclusion: { in: [ true, false ] }
  validates :forward_to, presence: { if: :forward }, length: { maximum: 255 }
  validates_each :forward_to, :allow_blank => true do |record, attr, value|
    record.errors.add(attr, 'is invalid') unless value.split(',', 50).all? { |element| element.match?(URI::MailTo::EMAIL_REGEXP) }
  end

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
