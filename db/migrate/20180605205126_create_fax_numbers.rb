class CreateFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_numbers do |t|
    	t.integer  :client_id
    	t.string   :fax_number_label
    	t.string   :fax_number_display_label
    	t.string   :fax_number, null: false

      t.timestamps
    end
  end
end
