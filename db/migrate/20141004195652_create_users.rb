class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :start_location
      t.string :end_location
      t.integer :phone_number
      t.integer :driver_id

      t.timestamps
    end
  end
end
