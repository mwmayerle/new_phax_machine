class CreateGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :groups do |t|
    	t.integer :fax_number_id, null: false
    	t.integer :client_id, null: false

    	t.string :group_label, null: false
    	t.string :display_label
    	t.string :fax_tag

      t.timestamps
    end
  end
end