admin = User.create!(
	email: ENV["ADMIN_EMAIL"],
	user_permission_attributes: { permission: UserPermission::ADMIN }
)

# manager = User.create!(
# 	email: 'matt@phaxio.com',
# 	user_permissions_attributes: [permission: UserPermission::MANAGER],
# 	caller_id_number: '17738675309'
# )

org = Organization.create(label: "Phaxio Test Company", admin_id: admin.id)
# org = Organization.create(label: "Phaxio Test Company", admin_id: admin.id, manager_id: manager.id)
# manager.update_attributes(organization_id: org.id)

user = User.create!(
	email: 'matt@phaxio.com',
	user_permission_attributes: { permission: UserPermission::USER },
	caller_id_number: '17738675309',
	organization_id: org.id
)

fax_number1 = FaxNumber.create!(fax_number: '17738675309', organization_id: org.id)
fax_number2 = FaxNumber.create!(fax_number: '12025550141', organization_id: org.id)

user.fax_numbers << fax_number2