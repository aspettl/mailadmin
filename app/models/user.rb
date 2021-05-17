class User < ApplicationRecord
  devise :database_authenticatable, :validatable, :timeoutable, :lockable
  has_many :domains, dependent: :destroy
end
