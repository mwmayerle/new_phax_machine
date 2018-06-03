class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
    	t.references :super_user
    	t.string     :group_name
    	t.string     :display_name
    	
    	t.timestamps
    end
  end
end
