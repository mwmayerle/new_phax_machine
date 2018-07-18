admin = User.create!(
	email: ENV["ADMIN_EMAIL"],
	user_permission_attributes: { permission: UserPermission::ADMIN }
)