# frozen_string_literal: true

class AddKnownAliasIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :domains, %i[type catchall catchall_target]
    add_index :accounts, %i[type forward forward_to]
    add_index :accounts, %i[type alias_target]
  end
end
