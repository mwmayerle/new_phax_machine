# Create the admin
admin = User.create!(
	email: ENV["ADMIN_EMAIL"],
	user_permission_attributes: { permission: UserPermission::ADMIN }
)

# Add all fax numbers from the Phaxio account
FaxNumber.format_and_retrieve_fax_numbers_from_api

###############################################################
# ROW FORMAT IS: ["organization", "user_emails", "fax_number"]
###############################################################

CSV.foreach("../Desktop/phaxmachine.csv", {headers: true}) do |row|
  current_org = Organization.find_or_create_by!(
  	label: row[0],
  	admin_id: admin.id
  )

  current_fax_number = FaxNumber.find_by!(fax_number: row[2])
  current_org.fax_numbers << current_fax_number unless current_org.fax_numbers.include?(current_fax_number)

  row[1].split(" ").each do |user_email|
	  new_user = User.create!(
  		email: user_email,
  		organization_id: current_org.id,
  		caller_id_number: row[2],
  		permission: 'user'
  	)
  	new_user.fax_numbers << current_fax_number
  end
end