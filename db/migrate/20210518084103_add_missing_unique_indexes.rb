# frozen_string_literal: true

class AddMissingUniqueIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :domains, :domain, unique: true
    add_index :accounts, :email, unique: true
  end
end
