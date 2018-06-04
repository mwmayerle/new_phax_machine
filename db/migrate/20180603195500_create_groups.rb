class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
    	t.references :group_leader, null: false
    	t.string     :group_name, null: false
    	t.string     :display_name
    	
    	t.timestamps
    end
  end
end
