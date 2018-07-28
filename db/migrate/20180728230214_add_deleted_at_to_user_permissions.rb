class AddDeletedAtToUserPermissions < ActiveRecord::Migration[5.2]
  def change
    add_column :user_permissions, :deleted_at, :datetime
    add_index :user_permissions, :deleted_at
  end
end
