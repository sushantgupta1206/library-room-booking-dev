# The User domain object uses secure password.
# User object has an emailId, password_digest,
# first_name, last_name and is identified as admin/library
# user. There is one preconfigured user indicated by the
# boolean flag is_preconfigured

class User < ApplicationRecord
  has_secure_password
end

=begin
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
=end
