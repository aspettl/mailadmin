# frozen_string_literal: true

class FixThreeStateBooleanColumns < ActiveRecord::Migration[7.0]
  def up
    change_column :domains, :enabled, :boolean, default: false, null: false
    change_column :accounts, :enabled, :boolean, default: false, null: false
  end

  def down
    change_column :domains, :enabled, :boolean, default: nil, null: true
    change_column :accounts, :enabled, :boolean, default: nil, null: true
  end
end
