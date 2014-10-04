class AddCostToUser < ActiveRecord::Migration
  def change
  	add_column :users, :cost, :float
  end
end
