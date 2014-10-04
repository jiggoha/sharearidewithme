class CreateDrivers < ActiveRecord::Migration
  def change
    create_table :drivers do |t|
      t.string :current_location

      t.timestamps
    end
  end
end
