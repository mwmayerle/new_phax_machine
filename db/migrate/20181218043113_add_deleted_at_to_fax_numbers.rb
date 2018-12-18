class AddDeletedAtToFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    add_column :fax_numbers, :deleted_at, :datetime
    add_index :fax_numbers, :deleted_at
  end
end
