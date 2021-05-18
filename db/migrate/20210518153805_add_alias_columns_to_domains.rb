class AddAliasColumnsToDomains < ActiveRecord::Migration[6.1]
  def change
    add_column :domains, :type, :integer, null: false, default: 0
    add_column :domains, :alias_target, :string
  end
end
