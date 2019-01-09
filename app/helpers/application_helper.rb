module ApplicationHelper
	# Notifies Admin and manager that a user has no caller ID number or the user is unlinked
	def check_for_revoked_caller_id_numbers_and_unlinked_users
		# deleted_at.nil? ensures soft-deleted users are not included.
		no_caller_id_users = @organization.users.select { |user| user.caller_id_number.nil? && user.deleted_at.nil? }
		unlinked_users = @organization.users.select { |user| user.fax_numbers == [] && user.deleted_at.nil? }
		if no_caller_id_users.present?
			flash.now[:alert] = no_caller_id_users.map { |user| user.email }.join(", ").concat(" have no caller ID number and cannot fax. Assign a caller ID number by clicking the #{@organization.label} Users button, and then click edit next to the user's name.")
		end
		if unlinked_users.present?
			message = unlinked_users.map { |user| user.email }.join(", ").concat(" are not linked to a fax number and cannot fax. Click #{@organization.label} to navigate to its dashboard, and assign a caller ID number by clicking the #{@organization.label} Users button, and then click edit next to the user's name. This process is demonstrated in the Readme in the sidebar. Click the 'Link/Unlink Users' button on your Dashboard to link these users to a fax number. ")
			# Display both messages or only one
			flash.now[:alert] ? flash.now[:alert] += "\n".concat(message) : flash.now[:alert] = message
		end
	end
end