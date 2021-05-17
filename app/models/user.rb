class User < ApplicationRecord
  devise :database_authenticatable, :validatable, :timeoutable, :lockable
end
