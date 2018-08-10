class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :uid, null: false
      t.string :login, null: false
      t.string :name
      t.string :url
      t.string :avatar_url
      t.string :provider, null: false

      t.timestamps
    end
  end
end
