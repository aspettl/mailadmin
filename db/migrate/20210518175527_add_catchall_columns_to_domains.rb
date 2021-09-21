# frozen_string_literal: true

class AddCatchallColumnsToDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :domains, :catchall, :boolean, null: false, default: false
    add_column :domains, :catchall_target, :string
  end
end
