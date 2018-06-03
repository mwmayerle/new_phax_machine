class CreateFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    create_table :fax_numbers do |t|
    	t.string   :fax_number, null: false
    	t.string   :fax_number_label
    	
    	t.timestamps
    end
  end
end
