class CreateUserFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :user_fax_numbers do |t|
    	t.integer  :user_id, null: false
    	t.integer  :fax_number_id, null: false

      t.timestamps
    end
  end
end
