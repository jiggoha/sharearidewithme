class DropLogs < ActiveRecord::Migration
  def change
  	drop_table :logs
  end
end
