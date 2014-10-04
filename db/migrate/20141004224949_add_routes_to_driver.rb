class AddRoutesToDriver < ActiveRecord::Migration
  def change
  	add_column :drivers, :route, :string
  end
end
