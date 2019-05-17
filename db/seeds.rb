# require 'csv'
# Create the admin
admin = User.create!(
	email: ENV["ADMIN_EMAIL"],
	user_permission_attributes: { permission: UserPermission::ADMIN }
)

FaxNumber.format_and_retrieve_fax_numbers_from_api