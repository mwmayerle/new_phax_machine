class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    	t.references  :super_user, index: true
    	t.boolean     :is_admin, default: false
    	t.string      :email, null: false
    	t.string      :fax_tag
    	t.string      :password_digest, null: false

      t.timestamps
    end
  end
end
