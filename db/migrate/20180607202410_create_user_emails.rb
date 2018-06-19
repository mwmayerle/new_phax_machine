class CreateUserEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :user_emails do |t|
    	t.integer  :client_id
    	t.integer  :user_id
    	t.string   :caller_id_number
    	t.string   :email_address, null: false
    	t.string   :fax_tag

      t.timestamps
    end
  end
end
