class CreateSuperUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :super_users do |t|
    	t.string   :super_user_email, null: false
    	t.string   :fax_tag
    	t.string   :password_digest, null: false

    	t.timestamps
    end
  end
end
