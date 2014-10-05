class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
    	t.string :tag
    	t.text :message

    	t.timestamps
    end
  end
end
