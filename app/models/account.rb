class Account < ApplicationRecord
  belongs_to :domain

  validates :email, presence: true
  validates :crypt, presence: true
end
