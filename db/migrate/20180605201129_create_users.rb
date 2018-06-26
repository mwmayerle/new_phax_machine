class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
    	t.integer :client_id
      t.string  :email, null: false, default: ""
      t.string  :type, null: false
      t.string  :situational
      t.string  :fax_tag

      t.timestamps
    end
  end
end
