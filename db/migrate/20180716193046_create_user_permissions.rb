class CreateUserPermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :user_permissions do |t|
    	t.integer  :user_id, null: false
    	t.string   :permission, null: false

    	t.timestamp
    end
  end
end
