class AddRoleToAdmins < ActiveRecord::Migration[8.1]
  def change
    add_column :admins, :role, :string, null: false, default: "manager"

    add_check_constraint :admins, "role IN ('manager', 'analyst')",
                         name: "admins_role_valid"
  end
end
