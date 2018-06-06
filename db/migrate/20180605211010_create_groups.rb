class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
    	t.string :group_label
    	t.string :display_label
    	t.string :fax_tag
    	t.integer :client_id

      t.timestamps
    end
  end
end
