class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes do |t|
    	t.string :tag
    	t.text :message

      t.timestamps
    end
  end
end
