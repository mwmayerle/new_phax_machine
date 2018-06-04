class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
    	t.references :group_leader
    	t.string     :group_name
    	t.string     :display_name
    	
    	t.timestamps
    end
  end
end
