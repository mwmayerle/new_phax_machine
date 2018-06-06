class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
    	t.integer  :admin_id
    	t.integer  :client_manager_id
    	t.string   :client_label

      t.timestamps
    end
  end
end
