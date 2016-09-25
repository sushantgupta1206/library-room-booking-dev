class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :emailId
      t.string :password_digest
      t.string  :first_name
      t.string  :last_name
      t.boolean :is_admin
      t.boolean :is_preconfigured

      t.timestamps
    end
  end
end
