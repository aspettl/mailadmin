class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.string :email
      t.string :crypt
      t.references :domain, null: false, foreign_key: true
      t.boolean :enabled

      t.timestamps
    end
  end
end
