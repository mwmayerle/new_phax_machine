class MailgunMailer < ApplicationMailer
	default from: ENV["SMTP_FROM"]

	def fax_email(email_addresses, email_subject, fax, fax_file_name = '', fax_file_contents = '')
		puts "**********************************************************************************"
  	p @email_addresses = email_addresses
  	p @email_subject = email_subject
  	p @fax = fax
  	mail.attachments[fax_file_name] = fax_file_contents if fax_file_name != ''
  	mail(to: @email_addresses, subject: @email_subject)
  end

  def failed_email_to_fax_email(sender, sent_fax_object)
		@sender = sender
		@sent_fax_object = sent_fax_object
  	mail(to: @sender, subject: "There was a problem delivering your fax")
  end
end


		MailgunMailer.fax_email(email_addresses, email_subject, @fax, fax_file_name, fax_file_contents).deliver_now
		MailgunMailer.fax_email(email_addresses, email_subject, @fax).deliver_now