class AddAliasColumnsToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :type, :integer, null: false, default: 0
    add_column :accounts, :alias_target, :string
  end
end
