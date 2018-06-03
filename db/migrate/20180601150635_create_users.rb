class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    	t.integer  :super_user_id, null: false

    	t.string   :user_email, null: false
    	t.string   :fax_tag
    	t.string   :password_digest, null: false

      t.timestamps
    end
  end
end
