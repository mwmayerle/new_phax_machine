class CreateEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :emails do |t|
    	t.integer  :group_id, null: false
    	t.string   :caller_id_number, null: false
    	t.string   :email

      t.timestamps
    end
  end
end
