class CreateFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_numbers do |t|
    	t.string   :fax_number_label
    	t.string   :fax_number
    	t.string   :faxable_type
    	t.integer  :faxable_id

      t.timestamps
    end
  end
end
