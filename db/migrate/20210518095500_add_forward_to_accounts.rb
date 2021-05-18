class AddForwardToAccounts < ActiveRecord::Migration[6.1]
  def change
    add_column :accounts, :forward, :boolean, null: false, default: false
    add_column :accounts, :forward_to, :string
  end
end
