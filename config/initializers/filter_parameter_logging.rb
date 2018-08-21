# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [
	:password, :password_digest, :permission, "user.password", "user.password_confirmation", "user.current_password"
]
