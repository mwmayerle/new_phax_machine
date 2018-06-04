class CreateUserGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :user_groups do |t|
    	t.references :group, index: true, null: false
    	t.references :user, index: true, null: false
    	
    	t.timestamps
    end
  end
end
