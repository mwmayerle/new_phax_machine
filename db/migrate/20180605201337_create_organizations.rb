class CreateOrganizations < ActiveRecord::Migration[5.2]
  def change
    create_table :organizations do |t|
    	t.integer  :admin_id, null: false
    	t.integer  :manager_id
    	t.string   :label, null: false
    	t.string   :fax_tag

      t.timestamps
    end
  end
end
