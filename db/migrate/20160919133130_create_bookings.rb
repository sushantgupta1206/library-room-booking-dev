class CreateBookings < ActiveRecord::Migration[5.0]
  def change
    create_table :bookings do |t|
      t.date   :day
      t.integer :start_time
      t.integer :end_time
      t.string   :attendees
      t.references :room, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
