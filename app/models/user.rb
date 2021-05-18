class User < ApplicationRecord
  devise :database_authenticatable, :validatable, :timeoutable, :lockable
  has_many :domains, dependent: :destroy
  has_many :accounts, through: :domains
end
