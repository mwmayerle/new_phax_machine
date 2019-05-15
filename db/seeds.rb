require 'csv'
# Create the admin
admin = User.create!(
	email: 'pontiacaztek@outlook.com',
	user_permission_attributes: { permission: UserPermission::ADMIN }
)

file = File.open('app/data.csv')
lol = CSV.parse(file, {headers: true}) do |row|
	fn = FaxNumber.find_or_create_by!(fax_number: Phonelib.parse(row[0]).e164)
	org = Organization.find_or_create_by!(admin_id: admin.id, label: row[1])
	org.fax_numbers << fn
	
	row[3..-1].each do |email|
		unless email.blank?
			fart = User.new(email: email, organization_id: org.id, caller_id_number: fn.fax_number, user_permission_attributes: {permission: UserPermission::USER})
			fart.save!
			fart.fax_numbers.push(fn) unless fart.fax_numbers.include?(fn)
		end
	end
end
# FaxNumber.format_and_retrieve_fax_numbers_from_api