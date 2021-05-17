class User < ApplicationRecord
  devise :database_authenticatable, :lockable, :validatable
end
