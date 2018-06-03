class CreateAdmins < ActiveRecord::Migration[5.2]
  def change
    create_table :admins do |t|
    	t.string   :admin_email, null: false
    	t.string   :password_digest, null: false

    	t.timestamps
    end
  end
end
