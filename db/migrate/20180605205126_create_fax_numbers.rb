class CreateFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_numbers do |t|
    	t.integer  :organization_id
    	t.string   :manager_label
    	t.string   :label
    	t.string   :fax_number, null: false

      t.timestamps
    end
  end
end