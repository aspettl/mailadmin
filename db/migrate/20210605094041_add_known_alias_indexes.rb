class AddKnownAliasIndexes < ActiveRecord::Migration[6.1]
  def change
    add_index :domains, [:type, :catchall, :catchall_target]
    add_index :accounts, [:type, :forward, :forward_to]
    add_index :accounts, [:type, :alias_target]
  end
end
