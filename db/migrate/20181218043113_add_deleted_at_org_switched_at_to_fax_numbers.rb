class AddDeletedAtOrgSwitchedAtToFaxNumbers < ActiveRecord::Migration[5.2]
  def change
    add_column :fax_numbers, :deleted_at, :datetime
    add_index :fax_numbers, :deleted_at
    add_column :fax_numbers, :org_switched_at, :datetime
    add_index :fax_numbers, :org_switched_at
  end
end
