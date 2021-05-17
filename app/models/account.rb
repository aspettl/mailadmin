class Account < ApplicationRecord
  belongs_to :domain

  attr_accessor :password

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_each :email do |record, attr, value|
    record.errors.add(attr, 'must be an account under the currently selected domain name') unless value.ends_with?("@#{record.domain.domain}")
  end
  validates :email, uniqueness: true
  validates :password, presence: true, on: :create
  validates :password, length: {minimum: 10}, allow_blank: true
  validates :domain_id, presence: true

  before_save :crypt_password

  def crypt_hash_method
    if self.crypt.starts_with?('$1')
      'MD5-CRYPT'
    elsif self.crypt.starts_with?('$6')
      'SHA512-CRYPT'
    else
      'DES-CRYPT'
    end
  end

  private
    def crypt_password
      self.crypt = sha512crypt(password) unless password.empty?
    end

    def sha512crypt(password)
      salt = SecureRandom.hex(8)
      password.crypt('$6$' + salt)
    end
end
