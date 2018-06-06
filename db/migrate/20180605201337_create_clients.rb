class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
    	t.integer  :admin_id, null: false
    	t.integer  :client_manager_id, null: false
    	t.string   :client_label, null: false
    	t.string   :fax_tag

      t.timestamps
    end
  end
end
