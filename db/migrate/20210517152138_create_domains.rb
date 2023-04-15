# frozen_string_literal: true

class CreateDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :domains do |t|
      t.string :domain
      t.references :user, null: false, foreign_key: true
      t.boolean :enabled # rubocop:disable Rails/ThreeStateBooleanColumn

      t.timestamps
    end
  end
end
