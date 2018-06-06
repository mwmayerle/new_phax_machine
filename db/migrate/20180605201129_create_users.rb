class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    	t.integer :client_id
    	
      t.string :type, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :fax_tag

      t.timestamps
    end
  end
end
