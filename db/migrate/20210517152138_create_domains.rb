class CreateDomains < ActiveRecord::Migration[6.1]
  def change
    create_table :domains do |t|
      t.string :domain
      t.references :user, null: false, foreign_key: true
      t.boolean :enabled

      t.timestamps
    end
  end
end