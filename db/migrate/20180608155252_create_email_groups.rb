class CreateEmailGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :email_groups do |t|
    	t.integer  :email_id, null: false
    	t.integer  :group_id, null: false

      t.timestamps
    end
  end
end
