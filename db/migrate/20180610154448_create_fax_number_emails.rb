class CreateFaxNumberEmails < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_number_emails do |t|
    	t.integer  :fax_number_id, null: false
    	t.integer  :email_id, null: false

      t.timestamps
    end
  end
end
