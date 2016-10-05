
# Building domain object has many rooms!
# Building has a name

class Building < ApplicationRecord
  has_many :rooms
end

=begin
class CreateBuildings < ActiveRecord::Migration[5.0]
  def change
    create_table :buildings do |t|
      t.string :name

      t.timestamps
    end
  end
end
=end
