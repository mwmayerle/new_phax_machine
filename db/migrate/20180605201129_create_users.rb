class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    	t.integer :organization_id
      t.string  :email, null: false
      t.string  :caller_id_number
      t.string  :fax_tag

      t.timestamps
    end
  end
end
